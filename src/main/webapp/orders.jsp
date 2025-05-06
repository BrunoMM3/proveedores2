<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
    String token = (String) session.getAttribute("token");
    String correo = (String) session.getAttribute("correo");
    if (token == null || correo == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Órdenes - Supplier Module</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css"> <!-- Asegúrate de tener este archivo -->
</head>
<body class="orders-view">
    <div class="container mt-4">
        <h2 class="mb-4">Órdenes - <%= correo %></h2>

        <div class="mb-3">
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary me-2">Volver al Dashboard</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Cerrar Sesión</a>
        </div>

        <h4>Lista de Órdenes</h4>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">${errorMessage}</div>
        </c:if>

        <c:if test="${empty orders}">
            <div class="alert alert-info">No hay órdenes disponibles.</div>
        </c:if>

        <c:if test="${not empty orders}">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Cliente</th>
                        <th>Ítems</th>
                        <th>Subtotal</th>
                        <th>Total</th>
                        <th>Estado</th>
                        <th>Fecha Creación</th>
                        <th>Método de Pago</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="order" items="${orders}">
                        <tr>
                            <td>${order.id}</td>
                            <td>${order.customerId}</td>
                            <td>
                                <ul>
                                    <c:forEach var="item" items="${order.items}">
                                        <li>
                                            Producto ID: ${item.productId}, 
                                            Cantidad: ${item.quantity}, 
                                            Precio: $<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </td>
                            <td>$<fmt:formatNumber value="${order.subtotal}" pattern="#,##0.00"/></td>
                            <td>$<fmt:formatNumber value="${order.total}" pattern="#,##0.00"/></td>
                            <td>${order.status}</td>
                            <td>${order.createdAt}</td>
                            <td>${order.paymentMethod}</td>
                            <td>
                                <c:if test="${order.editable}">
                                    <button class="btn btn-warning btn-sm update-order"
                                            data-id="${order.id}"
                                            data-customer-id="${order.customerId}"
                                            data-items="${order.itemsJson}"
                                            data-subtotal="${order.subtotal}"
                                            data-total="${order.total}"
                                            data-status="${order.status}"
                                            data-created-at="${order.createdAt}"
                                            data-payment-method="${order.paymentMethod}"
                                            data-bs-toggle="modal"
                                            data-bs-target="#updateModal">Actualizar</button>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>

        <!-- Modal para Actualizar Estado -->
        <div class="modal fade" id="updateModal" tabindex="-1" aria-labelledby="updateModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <form action="orders" method="post" enctype="multipart/form-data" id="updateOrderForm">
                        <div class="modal-header">
                            <h5 class="modal-title" id="updateModalLabel">Actualizar Estado</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" id="updateId" name="id">
                            <input type="hidden" id="updateCustomerId" name="customerId">
                            <input type="hidden" id="updateItems" name="items">
                            <input type="hidden" id="updateSubtotal" name="subtotal">
                            <input type="hidden" id="updateTotal" name="total">
                            <input type="hidden" id="updateCreatedAt" name="createdAt">
                            <input type="hidden" id="updatePaymentMethod" name="paymentMethod">
                            <div class="mb-3">
                                <label for="updateStatus" class="form-label">Estado</label>
                                <select class="form-control" id="updateStatus" name="status" required>
                                    <option value="Pendiente">Pendiente</option>
                                    <option value="Completado">Completado</option>
                                    <option value="Cancelado">Cancelado</option>
                                </select>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="submit" class="btn btn-primary">Guardar Cambios</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Modal para Mensajes -->
        <div class="modal fade" id="messageModal" tabindex="-1" aria-labelledby="messageModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="messageModalLabel">Notificación</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <c:choose>
                            <c:when test="${not empty error}">
                                <p class="text-danger">${error}</p>
                            </c:when>
                            <c:when test="${not empty message}">
                                <p class="text-success">${message}</p>
                            </c:when>
                            <c:otherwise>
                                <p>No se recibió ningún mensaje.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" data-bs-dismiss="modal" onclick="clearSessionAttributes()">Aceptar</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function clearSessionAttributes() {
            fetch('${pageContext.request.contextPath}/clearMessages', { method: 'POST' });
        }

        document.addEventListener('DOMContentLoaded', function() {
            document.querySelectorAll('.update-order').forEach(button => {
                button.addEventListener('click', function () {
                    document.getElementById('updateId').value = this.dataset.id;
                    document.getElementById('updateCustomerId').value = this.dataset.customerId;
                    document.getElementById('updateItems').value = this.dataset.items;
                    document.getElementById('updateSubtotal').value = this.dataset.subtotal;
                    document.getElementById('updateTotal').value = this.dataset.total;
                    document.getElementById('updateStatus').value = this.dataset.status;
                    document.getElementById('updateCreatedAt').value = this.dataset.createdAt;
                    document.getElementById('updatePaymentMethod').value = this.dataset.paymentMethod;
                });
            });

            <% if (message != null || error != null) { %>
                new bootstrap.Modal(document.getElementById('messageModal')).show();
            <% } %>
        });
    </script>
</body>
</html>
