<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte Detallado de Compras</title>
    <style>
        body {
            font-family: 'Helvetica', 'Arial', sans-serif;
            font-size: 12px;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 20px;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        h1 {
            color: #2c3e50;
            font-size: 28px;
            margin-bottom: 5px;
        }
        .header p {
            color: #7f8c8d;
            font-size: 14px;
            margin: 5px 0;
        }
        .summary {
            background-color: #ecf0f1;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 30px;
        }
        .summary h2 {
            color: #2980b9;
            font-size: 18px;
            margin-top: 0;
        }
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }
        .summary-item {
            background-color: #fff;
            border-radius: 3px;
            padding: 10px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .summary-item strong {
            display: block;
            font-size: 16px;
            color: #34495e;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
            font-size: 11px;
        }
        th, td {
            border: 1px solid #bdc3c7;
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #3498db;
            color: white;
            font-weight: bold;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .footer {
            text-align: center;
            font-size: 10px;
            color: #7f8c8d;
            margin-top: 30px;
            border-top: 1px solid #bdc3c7;
            padding-top: 10px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Reporte Detallado de Compras</h1>
        <h4>Usuario: {{ $userName }}</h4>
        <p>Período: {{ \Carbon\Carbon::parse($startDate)->format('d/m/Y') }} - {{ \Carbon\Carbon::parse($endDate)->format('d/m/Y') }}</p>
        <p>Generado el: {{ now()->format('d/m/Y H:i:s') }}</p>
    </div>

    <div class="summary">
        <h2>Resumen de Compras</h2>
        <div class="summary-grid">
            <div class="summary-item">
                <strong>{{ number_format($totalPurchases, 2) }} Bs</strong>
                Total de Compras
            </div>
            <div class="summary-item">
                <strong>{{ $totalProducts }}</strong>
                Productos Comprados
            </div>
            <div class="summary-item">
                <strong>{{ $purchases->count() }}</strong>
                Transacciones
            </div>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th>ID Compra</th>
                <th>Usuario</th>
                <th>Producto</th>
                <th>Cantidad</th>
                <th>Precio Unitario</th>
                <th>Subtotal</th>
                <th>Fecha y Hora</th>
            </tr>
        </thead>
        <tbody>
            @foreach($purchases as $purchase)
            <tr>
                <td>{{ $purchase->purchase_id }}</td>
                <td class="user-column">{{ optional($purchase->purchase)->user->name ?? 'N/A' }}</td>
                <td>{{ $purchase->product->name ?? 'N/A' }}</td>
                <td>{{ $purchase->quantity }}</td>
                <td>{{ number_format($purchase->unit_price, 2) }} Bs</td>
                <td>{{ number_format($purchase->subtotal, 2) }} Bs</td>
                <td>{{ optional($purchase->purchase)->created_at?->format('d/m/Y H:i:s') ?? 'Sin fecha' }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <div class="footer">
        <p>Este es un reporte generado automáticamente. Para cualquier consulta, por favor contacte al departamento de compras.</p>
    </div>
</body>
</html>