import React from "react";

export default function ItemTable({ items, onEdit, onDelete }) {
  const formatCurrency = (value) =>
    new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
    }).format(value);

  return (
    <div className="overflow-x-auto">
      <table className="w-full border text-sm sm:text-base">
        <thead>
          <tr className="bg-gray-200">
            <th className="border p-2">ID</th>
            <th className="border p-2">Name</th>
            <th className="border p-2 text-center w-24">Kelola Stok?</th>
            <th className="border p-2 w-20">Stock</th>
            <th className="border p-2">Buy Price</th>
            <th className="border p-2">Price</th>
            <th className="border p-2 w-32">Actions</th>
          </tr>
        </thead>
        <tbody>
          {items.map((it) => (
            <tr key={it.id} className="hover:bg-gray-50 flex-col sm:table-row">
              <td className="border p-2 text-center">{it.id}</td>
              <td className="border p-2 font-medium break-words max-w-[150px] sm:max-w-xs">
                {it.name}
              </td>
              <td className="border p-2 text-center">
                {it.is_stock_managed ? (
                  <span className="bg-green-100 text-green-800 text-xs font-medium px-2.5 py-0.5 rounded">
                    Ya
                  </span>
                ) : (
                  <span className="bg-gray-100 text-gray-800 text-xs font-medium px-2.5 py-0.5 rounded">
                    Tidak
                  </span>
                )}
              </td>
              <td className="border p-2 text-center">
                {it.is_stock_managed ? it.stock : "-"}
              </td>
              <td className="border p-2 text-sm sm:text-base whitespace-nowrap">
                {formatCurrency(it.buy_price)}
              </td>
              <td className="border p-2 text-sm sm:text-base whitespace-nowrap">
                {formatCurrency(it.price)}
              </td>
              <td className="border p-2 space-y-1 sm:space-y-0 sm:space-x-2 text-center">
                <button
                  onClick={() => onEdit(it)}
                  className="bg-yellow-500 hover:bg-yellow-600 text-white px-2 py-1 rounded text-xs sm:text-sm"
                >
                  Edit
                </button>
                <button
                  onClick={() => onDelete(it.id)}
                  className="bg-red-600 hover:bg-red-700 text-white px-2 py-1 rounded text-xs sm:text-sm"
                >
                  Delete
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
