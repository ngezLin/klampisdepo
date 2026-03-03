import { useEffect, useState, useCallback } from "react";
import { getInventoryHistory } from "../services/inventoryService";
import { getItemsPaginated } from "../services/transactionService";
import SearchableSelect from "../components/common/SearchableSelect";

export default function InventoryHistory() {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(false);

  // Filters
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [selectedItem, setSelectedItem] = useState("");
  const [selectedItemLabel, setSelectedItemLabel] = useState(""); // To persist name if not in search results
  const [type, setType] = useState("");
  const [items, setItems] = useState([]);

  // Item Pagination
  const [itemsPage, setItemsPage] = useState(1);
  const [hasMoreItems, setHasMoreItems] = useState(false);
  const [loadingMoreItems, setLoadingMoreItems] = useState(false);
  const [itemSearchTerm, setItemSearchTerm] = useState("");

  // Pagination for Logs
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const itemsPerPage = 10;

  const fetchItems = useCallback(async (search = "", page = 1) => {
    try {
      if (page > 1) setLoadingMoreItems(true);

      const res = await getItemsPaginated({
        name: search,
        page: page,
        limit: 20,
      });

      if (page === 1) {
        setItems(res.data || []);
      } else {
        setItems((prev) => [...prev, ...(res.data || [])]);
      }

      setHasMoreItems(page < (res.meta?.totalPages || res.total_pages || 1));
      return res.data || [];
    } catch (err) {
      console.error("Failed to fetch items for filter", err);
      return [];
    } finally {
      setLoadingMoreItems(false);
    }
  }, []);

  useEffect(() => {
    const initData = async () => {
      const itemsList = await fetchItems();
      if (!selectedItem && itemsList.length > 0) {
        const firstItem = itemsList[0];
        setSelectedItem(firstItem.id);
        setSelectedItemLabel(firstItem.name);
      }
    };
    initData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    fetchHistory();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentPage, startDate, endDate, selectedItem, type]);

  const handleItemSearch = useCallback(
    (val) => {
      setItemSearchTerm(val);
      setItemsPage(1);
      fetchItems(val, 1);
    },
    [fetchItems],
  );

  const handleLoadMoreItems = useCallback(() => {
    const nextPage = itemsPage + 1;
    setItemsPage(nextPage);
    fetchItems(itemSearchTerm, nextPage);
  }, [itemsPage, itemSearchTerm, fetchItems]);

  const fetchHistory = async () => {
    setLoading(true);
    try {
      if (!selectedItem) {
        setLogs([]);
        setTotalPages(1);
        setLoading(false);
        return;
      }

      const filters = {
        item_id: selectedItem,
        start_date: startDate,
        end_date: endDate,
        type: type !== "all" ? type : "",
      };

      const res = await getInventoryHistory(currentPage, itemsPerPage, filters);

      setLogs(res.data || []);
      setTotalPages(res.total_pages || 1);
      setCurrentPage(res.page || 1);
    } catch (err) {
      console.error("Failed to fetch inventory history:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleClearFilters = () => {
    setStartDate("");
    setEndDate("");
    setSelectedItem("");
    setType("");
    setCurrentPage(1);
  };

  return (
    <div className="p-4 sm:p-6 bg-gray-950 min-h-screen text-gray-100">
      <h1 className="text-2xl font-bold mb-6 text-white tracking-tight">
        Inventory History
      </h1>

      {/* Filters */}
      {/* Filters Overlay */}
      <div className="relative z-30 bg-gray-900/50 backdrop-blur-sm p-6 rounded-2xl shadow-xl mb-8 grid grid-cols-1 md:grid-cols-5 gap-6 items-end border border-white/5">
        <div>
          <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-2 ml-1">
            Item
          </label>
          <SearchableSelect
            options={items}
            value={Number(selectedItem)}
            onChange={(val) => {
              setSelectedItem(val);
              // Find name to persist label
              const item = items.find((i) => i.id === val);
              if (item) setSelectedItemLabel(item.name);
              setCurrentPage(1);
            }}
            onSearch={handleItemSearch}
            selectedLabel={selectedItemLabel}
            placeholder="Select Item"
            className="w-full"
            onLoadMore={handleLoadMoreItems}
            hasMore={hasMoreItems}
            loadingMore={loadingMoreItems}
          />
        </div>

        <div>
          <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-2 ml-1">
            Type
          </label>
          <select
            className="w-full bg-gray-800 border-gray-700 rounded-xl px-4 py-2.5 text-white focus:ring-2 focus:ring-blue-500/50 outline-none transition-all"
            value={type}
            onChange={(e) => {
              setType(e.target.value);
              setCurrentPage(1);
            }}
          >
            <option value="">All Types</option>
            <option value="sale">Sale</option>
            <option value="restock">Restock</option>
            <option value="adjustment">Adjustment</option>
            <option value="refund">Refund</option>
          </select>
        </div>

        <div>
          <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-2 ml-1">
            Start Date
          </label>
          <input
            type="date"
            className="w-full bg-gray-800 border-gray-700 rounded-xl px-4 py-2 text-white focus:ring-2 focus:ring-blue-500/50 outline-none transition-all"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
          />
        </div>

        <div>
          <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-2 ml-1">
            End Date
          </label>
          <input
            type="date"
            className="w-full bg-gray-800 border-gray-700 rounded-xl px-4 py-2 text-white focus:ring-2 focus:ring-blue-500/50 outline-none transition-all"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
          />
        </div>

        <div>
          <button
            onClick={handleClearFilters}
            className="w-full bg-gray-800 border border-gray-700 hover:bg-gray-700 text-gray-300 font-bold py-2.5 px-4 rounded-xl transition-all active:scale-95"
          >
            Clear Filters
          </button>
        </div>
      </div>

      {/* Table */}
      <div className="bg-gray-900/50 backdrop-blur-sm rounded-2xl shadow-xl border border-white/5 overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-800">
          <thead className="bg-black/20">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Date
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Item
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Type
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Change
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Final Stock
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Reference
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Note
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                User
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-800/50">
            {loading ? (
              <tr>
                <td
                  colSpan="8"
                  className="px-6 py-12 text-center text-gray-500 italic"
                >
                  Loading logs...
                </td>
              </tr>
            ) : !selectedItem ? (
              <tr>
                <td
                  colSpan="8"
                  className="px-6 py-12 text-center text-gray-500 italic"
                >
                  Please select an item to view its inventory history.
                </td>
              </tr>
            ) : logs.length === 0 ? (
              <tr>
                <td
                  colSpan="8"
                  className="px-6 py-12 text-center text-gray-500 italic"
                >
                  No inventory logs found for this item.
                </td>
              </tr>
            ) : (
              logs.map((log) => (
                <tr
                  key={log.id}
                  className="hover:bg-white/5 transition-colors group"
                >
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                    {new Date(log.created_at).toLocaleString("id-ID")}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-white group-hover:text-blue-400 transition-colors">
                    {log.item?.name || "-"}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    <span
                      className={`px-2 py-0.5 rounded-full text-[10px] uppercase font-black border ${
                        log.type === "sale"
                          ? "bg-blue-500/10 text-blue-400 border-blue-500/20"
                          : log.type === "restock"
                            ? "bg-green-500/10 text-green-400 border-green-500/20"
                            : log.type === "adjustment"
                              ? "bg-purple-500/10 text-purple-400 border-purple-500/20"
                              : log.type === "refund"
                                ? "bg-orange-500/10 text-orange-400 border-orange-500/20"
                                : "bg-gray-500/10 text-gray-400 border-gray-500/20"
                      }`}
                    >
                      {log.type}
                    </span>
                  </td>
                  <td
                    className={`px-6 py-4 whitespace-nowrap text-sm font-bold ${log.change > 0 ? "text-green-500" : "text-red-500"}`}
                  >
                    {log.change > 0 ? `+${log.change}` : log.change}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-white font-mono">
                    {log.final_stock}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 font-mono">
                    {log.reference_id || "-"}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-400 max-w-xs truncate">
                    {log.note || "-"}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {log.user ? log.user.username : "-"}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between mt-8 bg-gray-900/40 p-4 rounded-2xl border border-white/5">
          <p className="text-xs text-gray-500 font-medium uppercase tracking-widest pl-2">
            Page <span className="text-gray-300">{currentPage}</span> of{" "}
            <span className="text-gray-300">{totalPages}</span>
          </p>
          <div className="flex gap-2">
            <button
              onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
              disabled={currentPage === 1}
              className="px-4 py-2 bg-gray-950 border border-white/10 rounded-xl text-gray-400 hover:text-white disabled:opacity-30 transition-all font-bold text-sm"
            >
              Prev
            </button>
            <button
              onClick={() =>
                setCurrentPage((prev) => Math.min(prev + 1, totalPages))
              }
              disabled={currentPage === totalPages}
              className="px-4 py-2 bg-gray-950 border border-white/10 rounded-xl text-gray-400 hover:text-white disabled:opacity-30 transition-all font-bold text-sm"
            >
              Next
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
