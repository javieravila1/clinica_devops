// Funciones globales mejoradas
document.addEventListener("DOMContentLoaded", function () {
  inicializarAplicacion();
});

function inicializarAplicacion() {
  // Inicializar tooltips
  const tooltipTriggerList = [].slice.call(
    document.querySelectorAll('[data-bs-toggle="tooltip"]')
  );
  const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });

  // Inicializar popovers
  const popoverTriggerList = [].slice.call(
    document.querySelectorAll('[data-bs-toggle="popover"]')
  );
  const popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    return new bootstrap.Popover(popoverTriggerEl);
  });

  // Configurar fechas por defecto
  configurarFechasPorDefecto();

  // Auto-ocultar alerts
  configurarAutoCierreAlerts();

  // Configurar validación de formularios
  configurarValidacionFormularios();
}

function configurarFechasPorDefecto() {
  const now = new Date();
  const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);

  if (document.getElementById("fechaDesde")) {
    document.getElementById("fechaDesde").value = firstDay
      .toISOString()
      .split("T")[0];
  }

  if (document.getElementById("fechaHasta")) {
    document.getElementById("fechaHasta").value = now
      .toISOString()
      .split("T")[0];
  }

  // Configurar datetime-local para citas
  const fechaInicioInput = document.querySelector('input[name="fecha_inicio"]');
  const fechaFinInput = document.querySelector('input[name="fecha_fin"]');

  if (fechaInicioInput && fechaFinInput && !fechaInicioInput.value) {
    const startDateTime = new Date(now.getTime() + 60 * 60 * 1000);
    const endDateTime = new Date(startDateTime.getTime() + 60 * 60 * 1000);

    fechaInicioInput.value = formatarParaDateTimeLocal(startDateTime);
    fechaFinInput.value = formatarParaDateTimeLocal(endDateTime);
  }
}

function configurarAutoCierreAlerts() {
  const alerts = document.querySelectorAll(".alert");
  alerts.forEach((alert) => {
    setTimeout(() => {
      if (alert.parentElement) {
        const bsAlert = new bootstrap.Alert(alert);
        bsAlert.close();
      }
    }, 5000);
  });
}

function configurarValidacionFormularios() {
  // Validación en tiempo real para formularios
  const forms = document.querySelectorAll("form[needs-validation]");
  forms.forEach((form) => {
    form.addEventListener("submit", function (event) {
      if (!form.checkValidity()) {
        event.preventDefault();
        event.stopPropagation();
      }
      form.classList.add("was-validated");
    });
  });
}

// Funciones de utilidad mejoradas
function formatDate(dateString) {
  if (!dateString) return "N/A";
  try {
    const date = new Date(dateString);
    return date.toLocaleDateString("es-ES", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    });
  } catch (e) {
    return "Fecha inválida";
  }
}

function formatTime(dateString) {
  if (!dateString) return "N/A";
  try {
    const date = new Date(dateString);
    return date.toLocaleTimeString("es-ES", {
      hour: "2-digit",
      minute: "2-digit",
    });
  } catch (e) {
    return "Hora inválida";
  }
}

function formatDateTime(dateString) {
  if (!dateString) return "N/A";
  try {
    const date = new Date(dateString);
    return date.toLocaleString("es-ES", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  } catch (e) {
    return "Fecha/hora inválida";
  }
}

function formatarParaDateTimeLocal(date) {
  return date.toISOString().slice(0, 16);
}

// Sistema de notificaciones mejorado
function showNotification(message, type = "info", duration = 5000) {
  // Crear contenedor si no existe
  let container = document.getElementById("notification-container");
  if (!container) {
    container = document.createElement("div");
    container.id = "notification-container";
    container.style.position = "fixed";
    container.style.top = "20px";
    container.style.right = "20px";
    container.style.zIndex = "9999";
    container.style.minWidth = "300px";
    document.body.appendChild(container);
  }

  // Crear notificación
  const notification = document.createElement("div");
  notification.className = `alert alert-${
    type === "error" ? "danger" : "success"
  } alert-dismissible fade show`;
  notification.style.cssText = `
        animation: slideInRight 0.3s ease;
        margin-bottom: 10px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    `;

  notification.innerHTML = `
        <div class="d-flex align-items-center">
            <i class="fas fa-${
              type === "error" ? "exclamation-triangle" : "check-circle"
            } me-2"></i>
            <span>${message}</span>
        </div>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;

  container.appendChild(notification);

  // Auto-remover
  setTimeout(() => {
    if (notification.parentElement) {
      notification.style.animation = "slideOutRight 0.3s ease";
      setTimeout(() => notification.remove(), 300);
    }
  }, duration);
}

// Animaciones CSS para notificaciones
const style = document.createElement("style");
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    
    .fade-in {
        animation: fadeIn 0.6s ease;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
`;
document.head.appendChild(style);

// Funciones de confirmación mejoradas
function confirmAction(message = "¿Está seguro de realizar esta acción?") {
  return new Promise((resolve) => {
    // Crear modal de confirmación personalizado
    const modalHtml = `
            <div class="modal fade" id="confirmModal" tabindex="-1">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title"><i class="fas fa-question-circle me-2"></i>Confirmar acción</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="text-center">
                                <i class="fas fa-exclamation-triangle text-warning fa-3x mb-3"></i>
                                <p class="mb-0">${message}</p>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" id="confirmCancel">Cancelar</button>
                            <button type="button" class="btn btn-primary" id="confirmAccept">Aceptar</button>
                        </div>
                    </div>
                </div>
            </div>
        `;

    const modalContainer = document.createElement("div");
    modalContainer.innerHTML = modalHtml;
    document.body.appendChild(modalContainer);

    const modal = new bootstrap.Modal(document.getElementById("confirmModal"));
    modal.show();

    document.getElementById("confirmAccept").onclick = () => {
      modal.hide();
      resolve(true);
    };

    document.getElementById("confirmCancel").onclick = () => {
      modal.hide();
      resolve(false);
    };

    modalContainer.addEventListener("hidden.bs.modal", () => {
      modalContainer.remove();
    });
  });
}

// Función para cargar datos via AJAX
async function cargarDatos(url, options = {}) {
  try {
    const response = await fetch(url, {
      headers: {
        "Content-Type": "application/json",
        ...options.headers,
      },
      ...options,
    });

    if (!response.ok) {
      throw new Error(`Error ${response.status}: ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    console.error("Error cargando datos:", error);
    showNotification("Error al cargar los datos", "error");
    throw error;
  }
}

// Exportar funciones globales
window.formatDate = formatDate;
window.formatTime = formatTime;
window.formatDateTime = formatDateTime;
window.confirmAction = confirmAction;
window.showNotification = showNotification;
window.cargarDatos = cargarDatos;
