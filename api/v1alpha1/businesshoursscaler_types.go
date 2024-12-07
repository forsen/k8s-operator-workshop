package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// EDIT THIS FILE!  THIS IS SCAFFOLDING FOR YOU TO OWN!
// Important: Run "make" to regenerate code after modifying this file
// NOTE: json tags are required.  Any new fields you add must have json tags for the fields to be serialized.

// BusinessHoursScalerSpec defines the desired state of BusinessHoursScaler
type BusinessHoursScalerSpec struct {
	Foo string `json:"foo,omitempty"`
}

// BusinessHoursScalerStatus defines the observed state of BusinessHoursScaler
type BusinessHoursScalerStatus struct {
}

// +kubebuilder:object:root=true
// +kubebuilder:subresource:status

// BusinessHoursScaler is the Schema for the businesshoursscalers API
type BusinessHoursScaler struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   BusinessHoursScalerSpec   `json:"spec,omitempty"`
	Status BusinessHoursScalerStatus `json:"status,omitempty"`
}

// +kubebuilder:object:root=true

// BusinessHoursScalerList contains a list of BusinessHoursScaler
type BusinessHoursScalerList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []BusinessHoursScaler `json:"items"`
}

func init() {
	SchemeBuilder.Register(&BusinessHoursScaler{}, &BusinessHoursScalerList{})
}
