/*


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// EDIT THIS FILE!  THIS IS SCAFFOLDING FOR YOU TO OWN!
// NOTE: json tags are required.  Any new fields you add must have json tags for the fields to be serialized.

// Firewall is the Schema for the firewalls API
// +kubebuilder:object:root=true
// +kubebuilder:subresource:status
type Firewall struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   FirewallSpec   `json:"spec,omitempty"`
	Status FirewallStatus `json:"status,omitempty"`
}

// FirewallList contains a list of Firewall
// +kubebuilder:object:root=true
type FirewallList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []Firewall `json:"items"`
}

// FirewallSpec defines the desired state of Firewall
type FirewallSpec struct {
	Enabled           bool           `json:"enabled,omitempty"`
	Interval          string         `json:"interval,omitempty"`
	NftablesExportURL string         `json:"nftablesexporterurl,omitempty"`
	DryRun            bool           `json:"dryrun,omitempty"`
	Ipv4RuleFile      string         `json:"ipv4rulefile,omitempty"`
	TrafficControl    TrafficControl `json:"trafficcontrol,omitempty"`
}

// FirewallStatus defines the observed state of Firewall
type FirewallStatus struct {
	Message       string        `json:"message,omitempty"`
	FirewallStats FirewallStats `json:"stats"`
	Updated       metav1.Time   `json:"lastRun,omitempty"`
}

// FirewallStats contains firewall statistics
type FirewallStats struct {
	RuleStats           RuleStatsByAction          `json:"rules"`
	TrafficControlStats TrafficControlStatsByIface `json:"trafficcontrol"`
}

// RuleStatsByAction contains firewall rule statistics groups by action: e.g. accept, drop, policy, masquerade
type RuleStatsByAction map[string]RuleStats

// RuleStats contains firewall rule statistics of all rules of an action
type RuleStats map[string]RuleStat

// RuleStat contains the statistics for a single nftables rule
type RuleStat struct {
	Counters map[string]int64 `json:"counters"`
}

// TrafficControl contains the tc settings.
type TrafficControl struct {
	Interfaces string               `json:"interfaces,omitempty"`
	Rules      []TrafficControlRule `json:"rules,omitempty"`
}

// TrafficControlRule contains the tc settings for a nic.
type TrafficControlRule struct {
	Interface string `json:"interface,omitempty"`
	Rate      string `json:"rate,omitempty"`
}

// TrafficControlStatsByIface containts statistics about traffic control rules by interface.
type TrafficControlStatsByIface map[string]TrafficControlStats

// TrafficControlStats contains statistics about traffic control rules.
type TrafficControlStats struct {
	Bytes      uint64 `json:"bytes"`
	Packets    uint64 `json:"packets"`
	Drops      uint64 `json:"drops"`
	Overlimits uint64 `json:"overlimits"`
	Requeues   uint64 `json:"requeues"`
	Backlog    uint64 `json:"backlog"`
	Qlen       uint64 `json:"qlen"`
}

func init() {
	SchemeBuilder.Register(&Firewall{}, &FirewallList{})
}
