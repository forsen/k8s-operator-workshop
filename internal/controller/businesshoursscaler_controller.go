package controller

import (
	"context"

	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	appsv1alpha1 "github.com/bekk/k8s-operator-workshop/api/v1alpha1"
)

// Important bits below - RBAC rules needed for the controller to function properly. These annotations
// are used by the controller-runtime library to generate the necessary RBAC rules for the controller.

// +kubebuilder:rbac:groups=apps.k8s.bekk.no,resources=businesshoursscalers,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=apps.k8s.bekk.no,resources=businesshoursscalers/status,verbs=get;update;patch
// +kubebuilder:rbac:groups=apps.k8s.bekk.no,resources=businesshoursscalers/finalizers,verbs=update

// Construct our reconciler struct with required fields
type BusinessHoursScalerReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

// SetupWithManager sets up the controller with the Manager.
func (r *BusinessHoursScalerReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&appsv1alpha1.BusinessHoursScaler{}).
		Complete(r)
}

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the BusinessHoursScaler object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.18.4/pkg/reconcile
func (r *BusinessHoursScalerReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	_ = log.FromContext(ctx)

	// TODO: Din logikk her

	return ctrl.Result{}, nil
}
