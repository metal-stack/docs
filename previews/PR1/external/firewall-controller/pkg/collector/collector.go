package collector

import (
	"io"
	"io/ioutil"
	"net/http"
	"strings"

	ctrl "sigs.k8s.io/controller-runtime"

	"github.com/go-logr/logr"
	"github.com/prometheus/prometheus/pkg/labels"
	"github.com/prometheus/prometheus/pkg/textparse"
)

type (
	// Collector scrapes the node-exporter
	Collector struct {
		logger logr.Logger
		url    string
	}
	// DeviceStat maps series to value
	DeviceStat map[string]int64
	// DeviceStats is grouped by ethernet device
	DeviceStats map[string]DeviceStat
)

var (
	seriesToCollect = map[string]string{
		"node_network_transmit_packets_total": "out",
		"node_network_receive_packets_total":  "in",
	}
)

// NewCollector create a new Collector
func NewCollector(logger *logr.Logger, url string) Collector {
	var log logr.Logger
	if logger == nil {
		log = ctrl.Log.WithName("collector")
	} else {
		log = *logger
	}
	return Collector{
		logger: log,
		url:    url,
	}
}

// Collect metrics from node-exporter
func (c Collector) Collect() (*DeviceStats, error) {
	resp, err := http.Get(c.url)
	if err != nil {
		c.logger.Error(err, "unable to get metrics from node-exporter")
		return nil, err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		c.logger.Error(err, "unable to consume metrics")
		return nil, err
	}

	parser := textparse.NewPromParser(body)

	stats := DeviceStats{}
	for {
		et, err := parser.Next()
		if err == io.EOF {
			break
		}
		switch et {
		case textparse.EntrySeries:
			m, _, v := parser.Series()
			useSeries := false
			for k := range seriesToCollect {
				if strings.HasPrefix(string(m), k) {
					useSeries = true
					continue
				}
			}
			if !useSeries {
				continue
			}
			var lbls labels.Labels
			parser.Metric(&lbls)

			var stat DeviceStat
			seriesName := ""
			deviceName := ""
			for _, l := range lbls {
				if l.Name == labels.MetricName {
					seriesName = seriesToCollect[l.Value]
				}
				if l.Name == "device" {
					deviceName = l.Value
				}
			}
			ds, ok := stats[deviceName]
			if !ok {
				stat = DeviceStat{}
			} else {
				stat = ds
			}
			stat[seriesName] = int64(v)
			stats[deviceName] = stat
		}
	}
	return &stats, nil
}
