import React from "react";

export default function ItemTable({ items, onEdit, onDelete }) {
  const formatCurrency = (value) =>
    new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
    }).format(value);

  return (
    <div className="w-full">
      <table className="w-full text-sm sm:text-base border-collapse">
        <thead className="hidden sm:table-header-group">
          <tr className="bg-gray-900 text-gray-300">
            <th className="border border-gray-800 p-2 text-left">ID</th>
            <th className="border border-gray-800 p-2 text-left">Name</th>
            <th className="border border-gray-800 p-2 text-center w-24">
              Kelola Stok?
            </th>
            <th className="border border-gray-800 p-2 text-center w-20">
              Stock
            </th>
            <th className="border border-gray-800 p-2 text-left">Buy Price</th>
            <th className="border border-gray-800 p-2 text-left">Price</th>
            <th className="border border-gray-800 p-2 text-center w-32">
              Actions
            </th>
          </tr>
        </thead>
        <tbody className="block sm:table-row-group">
          {items.map((it) => (
            <tr
              key={it.id}
              className="block sm:table-row bg-gray-900 border border-gray-800 sm:border-0 mb-4 sm:mb-0 rounded-lg sm:rounded-none shadow-sm sm:shadow-none hover:bg-gray-800/50 transition-colors"
            >
              <td className="flex justify-between sm:table-cell sm:border border-gray-800 p-2 border-b sm:border-b-0">
                <span className="font-semibold sm:hidden text-gray-400">
                  ID
                </span>
                <span className="text-right sm:text-center">{it.id}</span>
              </td>
              <td className="flex justify-between sm:table-cell sm:border border-gray-800 p-2 border-b sm:border-b-0 break-words">
                <span className="font-semibold sm:hidden text-gray-400">
                  Name
                </span>
                <span className="text-right sm:text-left font-medium max-w-[200px] sm:max-w-xs text-white">
                  {it.name}
                </span>
              </td>
              <td className="flex justify-between items-center sm:table-cell sm:border border-gray-800 p-2 border-b sm:border-b-0">
                <span className="font-semibold sm:hidden text-gray-400">
                  Kelola Stok?
                </span>
                <span className="text-right sm:text-center">
                  {it.is_stock_managed ? (
                    <span className="bg-green-900/30 text-green-400 text-xs font-medium px-2.5 py-0.5 rounded border border-green-800/50">
                      Ya
                    </span>
                  ) : (
                    <span className="bg-gray-800 text-gray-400 text-xs font-medium px-2.5 py-0.5 rounded border border-gray-700">
                      Tidak
                    </span>
                  )}
                </span>
              </td>
              <td className="flex justify-between sm:table-cell sm:border border-gray-800 p-2 border-b sm:border-b-0 text-white">
                <span className="font-semibold sm:hidden text-gray-400">
                  Stock
                </span>
                <span className="text-right sm:text-center">
                  {it.is_stock_managed ? it.stock : "-"}
                </span>
              </td>
              <td className="flex justify-between sm:table-cell sm:border border-gray-800 p-2 border-b sm:border-b-0 text-white">
                <span className="font-semibold sm:hidden text-gray-400">
                  Buy Price
                </span>
                <span className="text-right sm:text-left whitespace-nowrap">
                  {formatCurrency(it.buy_price)}
                </span>
              </td>
              <td className="flex justify-between sm:table-cell sm:border border-gray-800 p-2 border-b sm:border-b-0 text-white">
                <span className="font-semibold sm:hidden text-gray-400">
                  Price
                </span>
                <span className="text-right sm:text-left whitespace-nowrap">
                  {formatCurrency(it.price)}
                </span>
              </td>
              <td className="flex justify-end sm:table-cell sm:border border-gray-800 p-2 space-x-2 sm:text-center">
                <button
                  onClick={() => onEdit(it)}
                  className="bg-yellow-500 hover:bg-yellow-600 text-white px-3 py-1.5 sm:px-2 sm:py-1 rounded text-sm sm:text-sm shadow-sm"
                >
                  Edit
                </button>
                <button
                  onClick={() => onDelete(it.id)}
                  className="bg-red-600 hover:bg-red-700 text-white px-3 py-1.5 sm:px-2 sm:py-1 rounded text-sm sm:text-sm shadow-sm"
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
