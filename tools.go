//go:build tools

// Official workaround to track tool dependencies with go modules:
// https://go.dev/wiki/Modules#how-can-i-track-tool-dependencies-for-a-module
package tools

import (
	// Declarative library for testing Kubernetes resources
	_ "github.com/kyverno/chainsaw"
	// Generate CRDs from Go types
	_ "sigs.k8s.io/controller-tools/cmd/controller-gen"
)
