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
            <th className="border p-2">Stock</th>
            <th className="border p-2">Buy Price</th>
            <th className="border p-2">Price</th>
            <th className="border p-2">Actions</th>
          </tr>
        </thead>
        <tbody>
          {items.map((it) => (
            <tr key={it.id} className="hover:bg-gray-50">
              <td className="border p-2 text-center">{it.id}</td>
              <td className="border p-2">{it.name}</td>
              <td className="border p-2 text-center">{it.stock}</td>
              <td className="border p-2">{formatCurrency(it.buy_price)}</td>
              <td className="border p-2">{formatCurrency(it.price)}</td>
              <td className="border p-2 space-x-2">
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
