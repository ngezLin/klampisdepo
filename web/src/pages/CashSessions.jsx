import React, { useState, useEffect, useCallback } from "react";
import cashSessionService from "../services/cashSessionService";
import { toast } from "react-hot-toast";
import {
  FaMoneyBillWave,
  FaCalculator,
  FaCashRegister,
  FaCheckCircle,
  FaExclamationTriangle,
  FaHistory,
  FaCalendarAlt,
} from "react-icons/fa";

export default function CashSessions() {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);
  const [inputCash, setInputCash] = useState("");
  const [loadingAction, setLoadingAction] = useState(false);

  // History State
  const [history, setHistory] = useState([]);
  const [historyLoading, setHistoryLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");

  const fetchCurrentSession = useCallback(async () => {
    setLoading(true);
    try {
      const response = await cashSessionService.getCurrentSession();
      setSession(response.data);
    } catch (error) {
      if (error.response && error.response.status === 404) {
        setSession(null);
      } else {
        console.error("Error fetching session:", error);
        toast.error("Gagal mengambil data sesi kas.");
      }
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchHistory = useCallback(async () => {
    setHistoryLoading(true);
    try {
      const response = await cashSessionService.getHistory({
        page,
        page_size: 5,
        start_date: startDate,
        end_date: endDate,
      });
      setHistory(response.data.data);
      setTotalPages(response.data.total_pages);
    } catch (error) {
      console.error("Error fetching history:", error);
      toast.error("Gagal mengambil riwayat sesi.");
    } finally {
      setHistoryLoading(false);
    }
  }, [page, startDate, endDate]);

  useEffect(() => {
    fetchCurrentSession();
    fetchHistory();
  }, [fetchCurrentSession, fetchHistory]);

  const handleOpenSession = async (e) => {
    e.preventDefault();
    if (!inputCash || inputCash < 0) {
      toast.error("Masukkan jumlah uang modal yang valid.");
      return;
    }

    setLoadingAction(true);
    try {
      const response = await cashSessionService.openSession(
        parseFloat(inputCash),
      );
      setSession(response.data);
      toast.success("Sesi kas berhasil dibuka!");
      setInputCash("");
    } catch (error) {
      console.error("Error opening session:", error);
      toast.error(error.response?.data?.error || "Gagal membuka sesi kas.");
    } finally {
      setLoadingAction(false);
    }
  };

  const handleCloseSession = async (e) => {
    e.preventDefault();
    if (!inputCash || inputCash < 0) {
      toast.error("Masukkan jumlah uang akhir yang valid.");
      return;
    }

    if (!window.confirm("Apakah Anda yakin ingin menutup sesi kas ini?")) {
      return;
    }

    setLoadingAction(true);
    try {
      const response = await cashSessionService.closeSession(
        parseFloat(inputCash),
      );
      setSession(response.data); // Updated session data (status closed)
      toast.success("Sesi kas berhasil ditutup!");
      setInputCash("");
    } catch (error) {
      console.error("Error closing session:", error);
      toast.error(error.response?.data?.error || "Gagal menutup sesi kas.");
    } finally {
      setLoadingAction(false);
    }
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(amount);
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleString("id-ID", {
      dateStyle: "medium",
      timeStyle: "short",
    });
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-500"></div>
      </div>
    );
  }

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold text-black mb-8 flex items-center gap-3">
        <FaCashRegister className="text-indigo-400" />
        Manajemen Sesi Kas
      </h1>

      {/* NO ACTIVE SESSION - SHOW OPEN FORM */}
      {!session || session.status === "closed" ? (
        <div className="bg-gray-800 rounded-xl shadow-lg border border-gray-700 overflow-hidden">
          <div className="p-6 border-b border-gray-700 bg-gray-800/50">
            <h2 className="text-xl font-semibold text-white flex items-center gap-2">
              <FaMoneyBillWave className="text-green-400" />
              Buka Sesi Baru
            </h2>
            <p className="text-gray-400 mt-1">
              Masukkan jumlah uang tunai (modal awal) di laci kasir untuk
              memulai sesi.
            </p>
          </div>

          <div className="p-8">
            {session && session.status === "closed" && (
              <div className="mb-6 p-4 bg-yellow-900/30 border border-yellow-700/50 rounded-lg text-yellow-200 flex items-center gap-3">
                <FaExclamationTriangle />
                <div>
                  <p className="font-bold">Sesi sebelumnya telah ditutup.</p>
                  <p className="text-sm opacity-80">
                    Silakan buka sesi baru untuk mulai bertransaksi.
                  </p>
                </div>
              </div>
            )}

            <form onSubmit={handleOpenSession} className="max-w-md">
              <div className="mb-6">
                <label className="block text-gray-300 text-sm font-bold mb-2">
                  Modal Awal (Opening Cash)
                </label>
                <div className="relative">
                  <span className="absolute left-3 top-3 text-gray-400">
                    Rp
                  </span>
                  <input
                    type="number"
                    value={inputCash}
                    onChange={(e) => setInputCash(e.target.value)}
                    className="w-full bg-gray-700 text-white border border-gray-600 rounded-lg py-3 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all"
                    placeholder="0"
                    required
                    min="0"
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={loadingAction}
                className={`w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-3 px-4 rounded-lg shadow-lg transform transition hover:scale-[1.02] flex justify-center items-center gap-2 ${
                  loadingAction ? "opacity-70 cursor-not-allowed" : ""
                }`}
              >
                {loadingAction ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    Memproses...
                  </>
                ) : (
                  <>
                    <FaCheckCircle /> Buka Sesi
                  </>
                )}
              </button>
            </form>
          </div>
        </div>
      ) : (
        /* ACTIVE SESSION DETAILS */
        <div className="space-y-6">
          {/* Session Info Card */}
          <div className="bg-gray-800 rounded-xl shadow-lg border border-gray-700 p-6">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 pb-4 border-b border-gray-700">
              <div>
                <h2 className="text-xl font-bold text-white flex items-center gap-2">
                  <span className="w-3 h-3 rounded-full bg-green-500 animate-pulse"></span>
                  Sesi Aktif
                </h2>
                <p className="text-sm text-gray-400 mt-1">
                  Sesi dimulai pada:{" "}
                  {new Date(session.OpenedAt).toLocaleString("id-ID")}
                </p>
              </div>
              <div className="mt-2 md:mt-0 py-1 px-3 bg-green-900/30 border border-green-700/50 rounded-full text-green-400 text-sm font-semibold">
                OPEN
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-gray-700/50 p-4 rounded-lg border border-gray-600/50">
                <p className="text-gray-400 text-sm mb-1">Modal Awal</p>
                <p className="text-2xl font-bold text-indigo-400">
                  {formatCurrency(session.OpeningCash)}
                </p>
              </div>
              {/* We won't show real-time sales here unless we fetch them or the user refreshes, 
                    since the backend updates only on close (based on calculation) 
                    BUT actually `total_cash_in` is calculated on Close in the backend controller shown.
                    So current details might be static until close. 
                    Let's stick to what we have. 
                */}
            </div>
          </div>

          {/* Close Session Form */}
          <div className="bg-gray-800 rounded-xl shadow-lg border border-gray-700 overflow-hidden">
            <div className="p-6 border-b border-gray-700 bg-red-900/10">
              <h2 className="text-xl font-semibold text-white flex items-center gap-2">
                <FaCalculator className="text-red-400" />
                Tutup Sesi
              </h2>
              <p className="text-gray-400 mt-1">
                Hitung uang tunai fisik di laci saat ini dan masukkan jumlahnya
                di bawah.
              </p>
            </div>

            <div className="p-8">
              <form onSubmit={handleCloseSession} className="max-w-md">
                <div className="mb-6">
                  <label className="block text-gray-300 text-sm font-bold mb-2">
                    Uang Tunai Akhir (Closing Cash)
                  </label>
                  <div className="relative">
                    <span className="absolute left-3 top-3 text-gray-400">
                      Rp
                    </span>
                    <input
                      type="number"
                      value={inputCash}
                      onChange={(e) => setInputCash(e.target.value)}
                      className="w-full bg-gray-700 text-white border border-gray-600 rounded-lg py-3 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all"
                      placeholder="Total uang fisik di laci"
                      required
                      min="0"
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={loadingAction}
                  className={`w-full bg-red-600 hover:bg-red-700 text-white font-bold py-3 px-4 rounded-lg shadow-lg transform transition hover:scale-[1.02] flex justify-center items-center gap-2 ${
                    loadingAction ? "opacity-70 cursor-not-allowed" : ""
                  }`}
                >
                  {loadingAction ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                      Menghitung & Menutup...
                    </>
                  ) : (
                    <>
                      <FaCheckCircle /> Tutup Sesi & Lihat Laporan
                    </>
                  )}
                </button>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* REPORT SUMMARY AFTER CLOSING */}
      {session && session.status === "closed" && (
        <div className="mt-8 bg-gray-800 rounded-xl shadow-lg border border-gray-700 p-6 animate-fade-in-up">
          <h2 className="text-xl font-bold text-white mb-4 border-b border-gray-700 pb-2">
            Ringkasan Penutupan
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <SummaryItem
              label="Modal Awal"
              value={session.OpeningCash}
              format={formatCurrency}
            />
            <SummaryItem
              label="Total Uang Masuk"
              value={session.TotalCashIn}
              format={formatCurrency}
              color="text-green-400"
            />
            <SummaryItem
              label="Total Kembalian"
              value={session.TotalChange}
              format={formatCurrency}
              color="text-red-400"
            />

            <div className="col-span-1 md:col-span-2 lg:col-span-3 h-px bg-gray-700 my-2"></div>

            <SummaryItem
              label="Seharusnya (System)"
              value={session.ExpectedCash}
              format={formatCurrency}
            />
            <SummaryItem
              label="Aktual (Fisik)"
              value={session.ClosingCash || 0}
              format={formatCurrency}
            />

            <div
              className={`p-4 rounded-lg border ${session.Difference === 0 ? "bg-green-900/20 border-green-700 text-green-400" : "bg-red-900/20 border-red-700 text-red-400"}`}
            >
              <p className="text-sm font-semibold mb-1">Selisih</p>
              <p className="text-2xl font-bold">
                {formatCurrency(session.Difference || 0)}
              </p>
              {session.Difference !== 0 && (
                <p className="text-xs mt-1">
                  {session.Difference > 0
                    ? "Lebih bayar / Uang berlebih"
                    : "Kurang / Uang hilang"}
                </p>
              )}
            </div>
          </div>

          <div className="mt-6 flex justify-end">
            <button
              onClick={() => {
                setSession(null);
                fetchHistory(); // Refresh history after closing
              }}
              className="bg-gray-700 hover:bg-gray-600 text-white px-4 py-2 rounded-lg transition"
            >
              Selesai & Tutup Laporan
            </button>
          </div>
        </div>
      )}

      {/* HISTORY SECTION */}
      <div className="mt-12">
        <h2 className="text-2xl font-bold text-black mb-6 flex items-center gap-3">
          <FaHistory className="text-indigo-400" />
          Riwayat Sesi Kas
        </h2>

        {/* Filters */}
        <div className="bg-gray-800 p-4 rounded-xl shadow-lg border border-gray-700 mb-6 flex flex-wrap gap-4 items-end">
          <div className="flex-1 min-w-[200px]">
            <label className="block text-gray-400 text-sm mb-1">
              Dari Tanggal
            </label>
            <div className="relative">
              <FaCalendarAlt className="absolute left-3 top-3 text-gray-500" />
              <input
                type="date"
                value={startDate}
                onChange={(e) => {
                  setStartDate(e.target.value);
                  setPage(1);
                }}
                className="w-full bg-gray-700 text-white border border-gray-600 rounded-lg py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          </div>
          <div className="flex-1 min-w-[200px]">
            <label className="block text-gray-400 text-sm mb-1">
              Sampai Tanggal
            </label>
            <div className="relative">
              <FaCalendarAlt className="absolute left-3 top-3 text-gray-500" />
              <input
                type="date"
                value={endDate}
                onChange={(e) => {
                  setEndDate(e.target.value);
                  setPage(1);
                }}
                className="w-full bg-gray-700 text-white border border-gray-600 rounded-lg py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          </div>
          <button
            onClick={() => {
              setStartDate("");
              setEndDate("");
              setPage(1);
            }}
            className="bg-gray-700 hover:bg-gray-600 text-white px-4 py-2 rounded-lg transition h-10 mb-[1px]"
          >
            Reset
          </button>
        </div>

        {/* History Table */}
        <div className="bg-gray-800 rounded-xl shadow-lg border border-gray-700 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-gray-300">
              <thead className="bg-gray-900/50 text-xs uppercase text-gray-400">
                <tr>
                  <th className="px-6 py-4">Waktu Buka</th>
                  <th className="px-6 py-4">Waktu Tutup</th>
                  <th className="px-6 py-4 text-right">Modal Awal</th>
                  <th className="px-6 py-4 text-right">Uang Akhir</th>
                  <th className="px-6 py-4 text-right">Selisih</th>
                  <th className="px-6 py-4 text-center">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-700">
                {historyLoading ? (
                  <tr>
                    <td colSpan="6" className="text-center py-8">
                      <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-500"></div>
                    </td>
                  </tr>
                ) : history.length === 0 ? (
                  <tr>
                    <td colSpan="6" className="text-center py-8 text-gray-500">
                      Tidak ada riwayat sesi ditemukan
                    </td>
                  </tr>
                ) : (
                  history.map((item) => (
                    <tr
                      key={item.ID}
                      className="hover:bg-gray-700/50 transition-colors"
                    >
                      <td className="px-6 py-4 whitespace-nowrap">
                        {formatDate(item.OpenedAt)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        {item.ClosedAt ? formatDate(item.ClosedAt) : "-"}
                      </td>
                      <td className="px-6 py-4 text-right">
                        {formatCurrency(item.OpeningCash)}
                      </td>
                      <td className="px-6 py-4 text-right">
                        {item.ClosingCash
                          ? formatCurrency(item.ClosingCash)
                          : "-"}
                      </td>
                      <td
                        className={`px-6 py-4 text-right font-bold ${
                          !item.Difference
                            ? ""
                            : item.Difference === 0
                              ? "text-green-400"
                              : "text-red-400"
                        }`}
                      >
                        {item.Difference !== undefined &&
                        item.Difference !== null
                          ? formatCurrency(item.Difference)
                          : "-"}
                      </td>
                      <td className="px-6 py-4 text-center">
                        <span
                          className={`px-3 py-1 rounded-full text-xs font-semibold ${
                            item.Status === "open"
                              ? "bg-green-900/50 text-green-400 border border-green-700"
                              : "bg-gray-700 text-gray-300 border border-gray-600"
                          }`}
                        >
                          {item.Status === "open" ? "AKTIF" : "SELESAI"}
                        </span>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          <div className="px-6 py-4 border-t border-gray-700 flex justify-between items-center">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page === 1}
              className="px-4 py-2 bg-gray-700 text-white rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-600 transition"
            >
              Previous
            </button>
            <span className="text-gray-400">
              Halaman {page} dari {totalPages}
            </span>
            <button
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={page === totalPages}
              className="px-4 py-2 bg-gray-700 text-white rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-600 transition"
            >
              Next
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function SummaryItem({ label, value, format, color = "text-white" }) {
  return (
    <div className="bg-gray-900/50 p-3 rounded border border-gray-700/50">
      <p className="text-gray-500 text-xs uppercase font-semibold">{label}</p>
      <p className={`text-lg font-mono ${color}`}>{format(value)}</p>
    </div>
  );
}
