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

  const [search, setSearch] = useState("");

  // Item Pagination
  const [itemsPage, setItemsPage] = useState(1);
  const [hasMoreItems, setHasMoreItems] = useState(false);
  const [loadingMoreItems, setLoadingMoreItems] = useState(false);
  const [itemSearchTerm, setItemSearchTerm] = useState("");

  // Pagination for Logs
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const itemsPerPage = 10;

  useEffect(() => {
    fetchItems();
  }, []);

  useEffect(() => {
    fetchHistory();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentPage, startDate, endDate, selectedItem, type, search]);

  const fetchItems = async (search = "", page = 1) => {
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
    } catch (err) {
      console.error("Failed to fetch items for filter", err);
    } finally {
      setLoadingMoreItems(false);
    }
  };

  const handleItemSearch = useCallback((val) => {
    setItemSearchTerm(val);
    setItemsPage(1);
    fetchItems(val, 1);
  }, []);

  const handleLoadMoreItems = () => {
    const nextPage = itemsPage + 1;
    setItemsPage(nextPage);
    fetchItems(itemSearchTerm, nextPage);
  };

  const fetchHistory = async () => {
    setLoading(true);
    try {
      const filters = {
        item_id: selectedItem,
        start_date: startDate,
        end_date: endDate,
        type: type !== "all" ? type : "",
        search: search,
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
    setSearch("");
    setCurrentPage(1);
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Inventory History</h1>

      {/* Filters */}
      <div className="bg-white p-4 rounded shadow mb-6 grid grid-cols-1 md:grid-cols-6 gap-4 items-end">
        <div className="md:col-span-1">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Search
          </label>
          <input
            type="text"
            placeholder="Ref ID, Note, User..."
            className="w-full border rounded p-2"
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setCurrentPage(1);
            }}
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
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
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Type
          </label>
          <select
            className="w-full border rounded p-2"
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
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Start Date
          </label>
          <input
            type="date"
            className="w-full border rounded p-2"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            End Date
          </label>
          <input
            type="date"
            className="w-full border rounded p-2"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
          />
        </div>

        <div>
          <button
            onClick={handleClearFilters}
            className="w-full bg-gray-200 hover:bg-gray-300 text-gray-800 font-semibold py-2 px-4 rounded"
          >
            Clear Filters
          </button>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded shadow overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
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
          <tbody className="bg-white divide-y divide-gray-200">
            {loading ? (
              <tr>
                <td colSpan="8" className="px-6 py-4 text-center text-gray-500">
                  Loading...
                </td>
              </tr>
            ) : logs.length === 0 ? (
              <tr>
                <td colSpan="8" className="px-6 py-4 text-center text-gray-500">
                  No logs found.
                </td>
              </tr>
            ) : (
              logs.map((log) => (
                <tr key={log.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {new Date(log.created_at).toLocaleString("id-ID")}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {log.item?.name || "-"}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 capitalize">
                    {log.type}
                  </td>
                  <td
                    className={`px-6 py-4 whitespace-nowrap text-sm font-semibold ${log.change > 0 ? "text-green-600" : "text-red-600"}`}
                  >
                    {log.change > 0 ? `+${log.change}` : log.change}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {log.final_stock}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {log.reference_id || "-"}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
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
        <div className="flex justify-center mt-4 space-x-2">
          <button
            onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
            disabled={currentPage === 1}
            className="px-3 py-1 border rounded disabled:opacity-50"
          >
            Prev
          </button>
          <span className="px-3 py-1">
            Page {currentPage} of {totalPages}
          </span>
          <button
            onClick={() =>
              setCurrentPage((prev) => Math.min(prev + 1, totalPages))
            }
            disabled={currentPage === totalPages}
            className="px-3 py-1 border rounded disabled:opacity-50"
          >
            Next
          </button>
        </div>
      )}
    </div>
  );
}
