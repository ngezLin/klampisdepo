import { useEffect, useState, useCallback } from "react";
import { getInventoryHistory } from "../services/inventoryService";
import { getItemsPaginated } from "../services/transactionService";
import SearchableSelect from "../components/common/SearchableSelect";

export default function Logs() {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(false);

  // Filters
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [selectedItem, setSelectedItem] = useState("");
  const [selectedItemLabel, setSelectedItemLabel] = useState("");
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

  const fetchHistory = useCallback(async () => {
    if (!selectedItem) {
      setLogs([]);
      setTotalPages(1);
      return;
    }
    setLoading(true);
    try {
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
  }, [currentPage, startDate, endDate, selectedItem, type]);

  useEffect(() => {
    fetchHistory();
  }, [fetchHistory]);

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

  const handleClearFilters = () => {
    setStartDate("");
    setEndDate("");
    setSelectedItem("");
    setType("");
    setCurrentPage(1);
  };

  return (
    <div className="p-4 sm:p-6 lg:p-10 min-h-screen max-w-7xl mx-auto overflow-hidden font-['Inter']">
      <div className="mb-10">
        <h1 className="text-4xl font-black text-white tracking-tight mb-2">
          Mutasi Stok Toko
        </h1>
        <p className="text-slate-500 font-medium italic">
          Pantau riwayat mutasi masuk, keluar, dan penyesuaian stok barang.
        </p>
      </div>

      <div className="space-y-6">
        {/* Filters Overlay */}
        <div className="relative z-30 bg-white/[0.02] backdrop-blur-xl p-6 rounded-2xl shadow-xl grid grid-cols-1 md:grid-cols-5 gap-6 items-end border border-white/5">
          <div>
            <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">
              Item / Barang
            </label>
            <SearchableSelect
              options={items}
              value={Number(selectedItem)}
              onChange={(val) => {
                setSelectedItem(val);
                const item = items.find((i) => i.id === val);
                if (item) setSelectedItemLabel(item.name);
                setCurrentPage(1);
              }}
              onSearch={handleItemSearch}
              selectedLabel={selectedItemLabel}
              placeholder="Pilih Item"
              className="w-full"
              onLoadMore={handleLoadMoreItems}
              hasMore={hasMoreItems}
              loadingMore={loadingMoreItems}
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">
              Tipe Mutasi
            </label>
            <select
              className="w-full bg-slate-900 border border-white/10 rounded-xl px-4 py-2.5 text-white focus:ring-2 focus:ring-blue-500/50 outline-none transition-all"
              value={type}
              onChange={(e) => {
                setType(e.target.value);
                setCurrentPage(1);
              }}
            >
              <option value="">Semua Tipe</option>
              <option value="sale">Penjualan</option>
              <option value="restock">Restock</option>
              <option value="adjustment">Penyesuaian (Manual)</option>
              <option value="refund">Refund</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">
              Tanggal Mulai
            </label>
            <input
              type="date"
              className="w-full bg-slate-900 border border-white/10 rounded-xl px-4 py-2 text-white focus:ring-2 focus:ring-blue-500/50 outline-none transition-all"
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">
              Tanggal Akhir
            </label>
            <input
              type="date"
              className="w-full bg-slate-900 border border-white/10 rounded-xl px-4 py-2 text-white focus:ring-2 focus:ring-blue-500/50 outline-none transition-all"
              value={endDate}
              onChange={(e) => setEndDate(e.target.value)}
            />
          </div>

          <div>
            <button
              onClick={handleClearFilters}
              className="w-full bg-slate-900 border border-white/10 hover:bg-slate-800 text-gray-300 font-bold py-2.5 px-4 rounded-xl transition-all active:scale-95"
            >
              Reset Filter
            </button>
          </div>
        </div>

        {/* Table */}
        <div className="bg-white/[0.02] backdrop-blur-xl rounded-2xl shadow-xl border border-white/5 overflow-x-auto">
          <table className="min-w-full divide-y divide-white/5">
            <thead className="bg-black/20">
              <tr>
                <th className="px-6 py-4 text-left text-xs font-medium text-slate-400 uppercase tracking-wider">
                  Waktu
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-slate-400 uppercase tracking-wider">
                  Nama Barang
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-slate-400 uppercase tracking-wider">
                  Tipe
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-slate-400 uppercase tracking-wider">
                  Jumlah Mutasi
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-slate-400 uppercase tracking-wider">
                  Stok Akhir
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-slate-400 uppercase tracking-wider">
                  Referensi ID
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-slate-400 uppercase tracking-wider">
                  Catatan
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-slate-400 uppercase tracking-wider">
                  User
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5">
              {loading ? (
                <tr>
                  <td colSpan="8" className="px-6 py-12 text-center text-slate-500 italic">
                    Memuat data...
                  </td>
                </tr>
              ) : !selectedItem ? (
                <tr>
                  <td colSpan="8" className="px-6 py-12 text-center text-slate-500 italic">
                    Harap pilih barang terlebih dahulu untuk melihat mutasi stok.
                  </td>
                </tr>
              ) : logs.length === 0 ? (
                <tr>
                  <td colSpan="8" className="px-6 py-12 text-center text-slate-500 italic">
                    Tidak ada log mutasi stok untuk barang ini.
                  </td>
                </tr>
              ) : (
                logs.map((log) => (
                  <tr key={log.id} className="hover:bg-white/[0.02] transition-colors group">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-400">
                      {new Date(log.created_at).toLocaleString("id-ID")}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-semibold text-white group-hover:text-blue-400 transition-colors">
                      {log.item?.name || "-"}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      <span
                        className={`px-2.5 py-1 rounded-full text-[10px] uppercase font-bold border ${
                          log.type === "sale"
                            ? "bg-blue-500/10 text-blue-400 border-blue-500/20"
                            : log.type === "restock"
                              ? "bg-emerald-500/10 text-emerald-400 border-emerald-500/20"
                              : log.type === "adjustment"
                                ? "bg-purple-500/10 text-purple-400 border-purple-500/20"
                                : log.type === "refund"
                                  ? "bg-orange-500/10 text-orange-400 border-orange-500/20"
                                  : "bg-slate-500/10 text-slate-400 border-slate-500/20"
                        }`}
                      >
                        {log.type}
                      </span>
                    </td>
                    <td className={`px-6 py-4 whitespace-nowrap text-sm font-black ${log.change > 0 ? "text-emerald-400" : "text-rose-400"}`}>
                      {log.change > 0 ? `+${log.change}` : log.change}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-white font-mono">
                      {log.final_stock}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-500 font-mono">
                      {log.reference_id || "-"}
                    </td>
                    <td className="px-6 py-4 text-sm text-slate-400 max-w-xs truncate">
                      {log.note || "-"}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-400">
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
          <div className="flex items-center justify-between mt-8 bg-white/[0.01] p-4 rounded-2xl border border-white/5">
            <p className="text-xs text-slate-500 font-medium uppercase tracking-widest pl-2">
              Halaman <span className="text-slate-300 font-bold">{currentPage}</span> dari{" "}
              <span className="text-slate-300 font-bold">{totalPages}</span>
            </p>
            <div className="flex gap-2">
              <button
                onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
                disabled={currentPage === 1}
                className="px-4 py-2 bg-slate-950 border border-white/10 rounded-xl text-slate-400 hover:text-white disabled:opacity-30 transition-all font-bold text-sm"
              >
                Sebelumnya
              </button>
              <button
                onClick={() => setCurrentPage((prev) => Math.min(prev + 1, totalPages))}
                disabled={currentPage === totalPages}
                className="px-4 py-2 bg-slate-950 border border-white/10 rounded-xl text-slate-400 hover:text-white disabled:opacity-30 transition-all font-bold text-sm"
              >
                Berikutnya
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
