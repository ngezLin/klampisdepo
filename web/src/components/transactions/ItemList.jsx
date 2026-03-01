import { useState, useEffect, useCallback } from "react";
import { getItems, searchItemsByName } from "../../services/itemService";
import { BASE_URL } from "../../services/api";
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

      {/* Grid view replacing table */}
      {items.length === 0 ? (
        <p className="text-gray-500 text-center py-10">No items found.</p>
      ) : (
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3">
          {items.map((item) => (
            <div
              key={item.id}
              onClick={() => addToCart(item)}
              className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden cursor-pointer hover:shadow-md hover:border-blue-300 transition-all flex flex-col active:scale-95 duration-150"
            >
              <div className="relative w-full pt-[100%] bg-gray-100 overflow-hidden">
                <img
                  src={
                    item.image_url
                      ? String(item.image_url).startsWith("http")
                        ? item.image_url
                        : `${BASE_URL}${item.image_url}`
                      : placeholder
                  }
                  alt={item.name}
                  className="absolute inset-0 w-full h-full object-cover"
                  loading="lazy"
                />
                {!item.is_stock_managed || item.stock > 0 ? null : (
                  <div className="absolute inset-0 bg-red-500 bg-opacity-30 flex items-center justify-center z-10">
                    <span className="bg-red-600 text-white text-xs font-bold px-2 py-1 rounded shadow-lg">
                      HABIS
                    </span>
                  </div>
                )}
              </div>
              <div className="p-2 sm:p-3 flex flex-col flex-1 gap-1">
                <h3 className="text-xs sm:text-sm font-semibold text-gray-800 line-clamp-2 leading-tight h-8 sm:h-10">
                  {item.name}
                </h3>
                <p
                  className="text-[10px] text-gray-500 uppercase tracking-widest truncate w-full h-4"
                  title={item.description || ""}
                >
                  {item.description || "-"}
                </p>
                <div className="mt-1 text-left">
                  <p className="text-blue-600 font-bold text-sm sm:text-base">
                    Rp {item.price.toLocaleString("id-ID")}
                  </p>
                  <p className="text-[10px] sm:text-xs text-gray-500 mt-0.5">
                    Stok:{" "}
                    {item.is_stock_managed ? (
                      <span
                        className={
                          item.stock <= 5 ? "text-orange-500 font-medium" : ""
                        }
                      >
                        {item.stock}
                      </span>
                    ) : (
                      "-"
                    )}
                  </p>
                </div>
              </div>
            </div>
          ))}
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
