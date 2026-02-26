import { useState, useEffect, useCallback } from "react";
import { getItems, searchItemsByName } from "../../services/itemService";
import Pagination from "../common/Pagination";

export default function ItemList({ addToCart }) {
  const [items, setItems] = useState([]);
  const [search, setSearch] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const itemsPerPage = 10;

  const placeholder =
    "https://lh5.googleusercontent.com/proxy/211Ca3xFzqt_aKp8B3LjO8T7etZyEKVXv2NN4wHJDIH0ZmcGBWKho21SCa19Bh6AmanXwC3MeP3mmaiWcGkFV_mDYZLhZ0UszlBVMLo7eGRvXXgnFAr9mvAJe6czDTPMKU-ja5rX0ItRgR2tpK077vt5yOV6ottZGMon2A=w160-h120-k-no";

  const fetchData = useCallback(async () => {
    try {
      let res;
      if (search.trim() === "") {
        res = await getItems(currentPage, itemsPerPage);
      } else {
        res = await searchItemsByName(search, currentPage, itemsPerPage);
      }

      const { data, meta } = res;

      setItems(data || []);
      setTotalPages(meta?.total_pages ?? meta?.totalPages ?? 1);
      setTotalItems(meta?.total_items ?? meta?.total ?? 0);
    } catch (err) {
      console.error("Failed fetching items:", err);
    }
  }, [search, currentPage, itemsPerPage]); // ⬅️ INI KUNCINYA

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return (
    <div className="flex-1 min-w-0 min-h-0 bg-gray-50 p-4 rounded shadow-inner overflow-y-auto">
      {/* Header + Search */}
      <div className="flex flex-col sm:flex-row justify-between items-center gap-3 mb-4">
        <h2 className="text-xl font-bold">Items</h2>

        <div className="relative w-full sm:w-1/2 lg:w-1/3">
          <input
            type="text"
            placeholder="Search items..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setCurrentPage(1);
            }}
            className="w-full px-3 py-2 border rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 pr-8"
          />
          {search && (
            <button
              type="button"
              onClick={() => {
                setSearch("");
                setCurrentPage(1);
              }}
              className="absolute right-2 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
            >
              ✕
            </button>
          )}
        </div>
      </div>

      {/* Table */}
      {items.length === 0 ? (
        <p className="text-gray-500 text-center py-10">No items found.</p>
      ) : (
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-100 border-b">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                    Image
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                    Name
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                    Description
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                    Price
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                    Stock
                  </th>
                </tr>
              </thead>

              <tbody className="divide-y divide-gray-200">
                {items.map((item) => (
                  <tr
                    key={item.id}
                    onClick={() => addToCart(item)}
                    className="hover:bg-blue-50 cursor-pointer transition duration-150"
                  >
                    <td className="px-4 py-3">
                      <img
                        src={
                          item.image_url
                            ? String(item.image_url).startsWith("http")
                              ? item.image_url
                              : `${process.env.REACT_APP_API_URL || "http://localhost:8080"}${item.image_url}`
                            : placeholder
                        }
                        alt={item.name}
                        className="w-16 h-16 object-cover rounded"
                      />
                    </td>
                    <td className="px-4 py-3 text-sm font-medium text-gray-800">
                      {item.name}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600 max-w-xs line-clamp-2">
                      {item.description || "Deskripsi tidak tersedia."}
                    </td>
                    <td className="px-4 py-3 text-sm font-semibold text-gray-800 whitespace-nowrap">
                      Rp {item.price.toLocaleString()}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600">
                      {item.is_stock_managed ? item.stock : "-"}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="mt-4 pb-4 px-2">
          <Pagination
            currentPage={currentPage}
            totalPages={totalPages}
            totalItems={totalItems}
            itemsPerPage={itemsPerPage}
            currentItemsCount={items.length}
            onNext={() => setCurrentPage((p) => Math.min(p + 1, totalPages))}
            onPrevious={() => setCurrentPage((p) => Math.max(p - 1, 1))}
            onPageChange={setCurrentPage}
          />
        </div>
      )}
    </div>
  );
}
