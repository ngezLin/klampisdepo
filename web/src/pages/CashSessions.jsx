import React, { useState, useEffect, useCallback } from "react";
import cashSessionService from "../services/cashSessionService";
import { formatCurrency } from "../utils/format";
import toast from "react-hot-toast";
import {
  Banknote,
  Calculator,
  Wallet,
  CheckCircle2,
  AlertTriangle,
  History,
  CalendarDays,
} from "lucide-react";
import StatCard from "../components/common/StatCard";
import Card from "../components/common/Card";
import Button from "../components/common/Button";

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

    setLoadingAction(true);
    try {
      const response = await cashSessionService.closeSession(
        parseFloat(inputCash),
      );
      setSession(response.data);
      toast.success("Sesi kas berhasil ditutup!");
      setInputCash("");
    } catch (error) {
      console.error("Error closing session:", error);
      toast.error(error.response?.data?.error || "Gagal menutup sesi kas.");
    } finally {
      setLoadingAction(false);
    }
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleString("id-ID", {
      dateStyle: "medium",
      timeStyle: "short",
    });
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center h-screen bg-[#0a0a0a]">
        <div className="animate-spin rounded-full h-10 w-10 border-4 border-blue-500 border-t-transparent"></div>
        <p className="mt-4 text-gray-500 font-medium italic">
          Menyiapkan manajemen kas...
        </p>
      </div>
    );
  }

  return (
    <div className="p-4 sm:p-6 bg-[#0a0a0a] min-h-screen text-gray-100 max-w-5xl mx-auto animate-in fade-in duration-700">
      <div className="mb-10">
        <h1 className="text-3xl font-black text-white tracking-tight flex items-center gap-3">
          <Wallet className="text-blue-500 w-8 h-8" />
          Manajemen Sesi Kas
        </h1>
        <p className="text-gray-500 mt-1 font-medium italic">
          Buka atau tutup sesi kasir untuk melacak mutasi dana.
        </p>
      </div>

      {!session || session.status === "closed" ? (
        <Card
          title="Buka Sesi Baru"
          subtitle="Mulai sesi transaksi dengan modal awal"
          className="mb-12 border-white/5 shadow-2xl"
        >
          <div className="max-w-md">
            {session && session.status === "closed" && (
              <div className="mb-8 p-4 bg-yellow-900/10 border border-yellow-500/20 rounded-2xl text-yellow-500 flex items-start gap-3">
                <AlertTriangle className="w-5 h-5 flex-shrink-0 mt-0.5" />
                <div className="text-sm">
                  <p className="font-black uppercase tracking-wider mb-1">
                    Sesi Sebelumnya Selesai
                  </p>
                  <p className="opacity-80">
                    Silakan masukkan modal awal baru untuk mulai berjualan lagi.
                  </p>
                </div>
              </div>
            )}

            <form onSubmit={handleOpenSession} className="space-y-6">
              <div>
                <label className="block text-gray-400 text-xs font-black uppercase tracking-widest mb-3">
                  Modal Awal (Tunai)
                </label>
                <div className="relative group">
                  <span className="absolute left-4 top-3.5 text-gray-500 font-bold group-focus-within:text-blue-500 transition-colors">
                    Rp
                  </span>
                  <input
                    type="number"
                    value={inputCash}
                    onChange={(e) => setInputCash(e.target.value)}
                    className="w-full bg-gray-900 text-white border border-white/10 rounded-2xl py-3.5 pl-12 pr-4 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all font-mono text-lg"
                    placeholder="0"
                    required
                    min="0"
                  />
                </div>
              </div>

              <Button
                type="submit"
                loading={loadingAction}
                fullWidth
                size="lg"
                icon={CheckCircle2}
              >
                Buka Sesi Sekarang
              </Button>
            </form>
          </div>
        </Card>
      ) : (
        <div className="space-y-8 mb-12">
          <Card
            title="Sesi Aktif"
            subtitle={`Dimulai ${new Date(session.OpenedAt).toLocaleString("id-ID")}`}
            className="border-green-500/10 shadow-green-500/5"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <StatCard
                label="Modal Awal"
                value={formatCurrency(session.OpeningCash)}
                icon={Banknote}
                colorClass="text-emerald-400"
              />
              <div className="p-6 bg-white/5 rounded-2xl border border-white/5 flex flex-col justify-center">
                <p className="text-gray-500 text-xs font-black uppercase tracking-widest mb-1 text-center">
                  Status
                </p>
                <div className="flex items-center justify-center gap-2 text-green-400 font-black text-xl">
                  <span className="w-2.5 h-2.5 rounded-full bg-green-500 animate-pulse"></span>
                  RUNNING
                </div>
              </div>
            </div>
          </Card>

          <Card
            title="Tutup Sesi"
            subtitle="Hitung uang fisik di laci saat ini"
            className="border-red-500/10 shadow-red-500/5"
          >
            <form onSubmit={handleCloseSession} className="max-w-md space-y-6">
              <div>
                <label className="block text-gray-400 text-xs font-black uppercase tracking-widest mb-3">
                  Uang Tunai Akhir (Fisik)
                </label>
                <div className="relative group">
                  <span className="absolute left-4 top-3.5 text-gray-500 font-bold group-focus-within:text-red-500 transition-colors">
                    Rp
                  </span>
                  <input
                    type="number"
                    value={inputCash}
                    onChange={(e) => setInputCash(e.target.value)}
                    className="w-full bg-gray-900 text-white border border-white/10 rounded-2xl py-3.5 pl-12 pr-4 focus:outline-none focus:ring-2 focus:ring-red-500/50 transition-all font-mono text-lg"
                    placeholder="Total uang kas"
                    required
                    min="0"
                  />
                </div>
              </div>

              <Button
                type="submit"
                variant="danger"
                loading={loadingAction}
                fullWidth
                size="lg"
                icon={Calculator}
              >
                Tutup Sesi & Hitung
              </Button>
            </form>
          </Card>
        </div>
      )}

      {session && session.status === "closed" && (
        <Card
          title="Ringkasan Penutupan"
          className="mb-12 animate-in slide-in-from-bottom-4 duration-500 border-blue-500/20 shadow-blue-500/5"
        >
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <StatCard
              label="Modal Awal"
              value={formatCurrency(session.OpeningCash)}
              icon={Banknote}
              colorClass="text-gray-400"
            />
            <StatCard
              label="Uang Masuk"
              value={formatCurrency(session.TotalCashIn)}
              icon={CheckCircle2}
              colorClass="text-emerald-400"
            />
            <StatCard
              label="Total Kembali"
              value={formatCurrency(session.TotalChange)}
              icon={AlertTriangle}
              colorClass="text-amber-400"
            />

            <div className="sm:col-span-2 lg:col-span-3 h-px bg-white/5 my-2"></div>

            <StatCard
              label="Estimasi Sistem"
              value={formatCurrency(session.ExpectedCash)}
              icon={Calculator}
              colorClass="text-blue-400"
            />
            <StatCard
              label="Uang Fisik"
              value={formatCurrency(session.ClosingCash || 0)}
              icon={Banknote}
              colorClass="text-white"
            />

            <div
              className={`p-6 rounded-2xl border ${session.Difference === 0 ? "bg-emerald-900/10 border-emerald-500/20 text-emerald-400" : "bg-red-900/10 border-red-500/20 text-red-400"}`}
            >
              <p className="text-xs font-black uppercase tracking-widest mb-1 opacity-60">
                Selisih
              </p>
              <p className="text-3xl font-black font-mono">
                {formatCurrency(session.Difference || 0)}
              </p>
              {session.Difference !== undefined && session.Difference !== 0 && (
                <p className="text-xs mt-2 font-medium italic opacity-80">
                  {session.Difference > 0
                    ? "⚠️ Ada kelebihan uang di kasir"
                    : "⚠️ Ada kekurangan uang di kasir"}
                </p>
              )}
            </div>
          </div>

          <div className="mt-8 flex justify-end">
            <Button
              variant="ghost"
              onClick={() => {
                setSession(null);
                fetchHistory();
              }}
            >
              Selesai & Tutup Laporan
            </Button>
          </div>
        </Card>
      )}

      <div className="mt-16">
        <h2 className="text-2xl font-black text-white mb-8 flex items-center gap-3">
          <History className="text-blue-400 w-6 h-6" />
          Riwayat Sesi
        </h2>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-8">
          <div className="relative group">
            <CalendarDays className="absolute left-3 top-3 text-gray-500 group-focus-within:text-blue-500 transition-colors w-4 h-4" />
            <input
              type="date"
              value={startDate}
              onChange={(e) => {
                setStartDate(e.target.value);
                setPage(1);
              }}
              className="w-full bg-gray-900 text-white border border-white/5 rounded-xl py-2.5 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-blue-500/50"
            />
          </div>
          <div className="relative group">
            <CalendarDays className="absolute left-3 top-3 text-gray-500 group-focus-within:text-blue-500 transition-colors w-4 h-4" />
            <input
              type="date"
              value={endDate}
              onChange={(e) => {
                setEndDate(e.target.value);
                setPage(1);
              }}
              className="w-full bg-gray-900 text-white border border-white/5 rounded-xl py-2.5 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-blue-500/50"
            />
          </div>
        </div>

        <Card className="px-0 py-0 overflow-hidden border-white/5 shadow-2xl">
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-white/5 text-gray-500 border-b border-white/5">
                  <th className="px-6 py-4 text-xs font-black uppercase tracking-widest">
                    Waktu Buka
                  </th>
                  <th className="px-6 py-4 text-xs font-black uppercase tracking-widest">
                    Waktu Tutup
                  </th>
                  <th className="px-6 py-4 text-xs font-black uppercase tracking-widest text-right">
                    Modal
                  </th>
                  <th className="px-6 py-4 text-xs font-black uppercase tracking-widest text-right">
                    Uang Akhir
                  </th>
                  <th className="px-6 py-4 text-xs font-black uppercase tracking-widest text-right">
                    Selisih
                  </th>
                  <th className="px-6 py-4 text-xs font-black uppercase tracking-widest text-center">
                    Status
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5">
                {historyLoading ? (
                  <tr>
                    <td colSpan="6" className="text-center py-12">
                      <div className="inline-block animate-spin rounded-full h-8 w-8 border-4 border-blue-500 border-t-transparent"></div>
                    </td>
                  </tr>
                ) : history.length === 0 ? (
                  <tr>
                    <td
                      colSpan="6"
                      className="text-center py-12 text-gray-600 italic"
                    >
                      Tidak ada riwayat sesi ditemukan
                    </td>
                  </tr>
                ) : (
                  history.map((item) => (
                    <tr
                      key={item.ID}
                      className="hover:bg-white/5 transition-colors group"
                    >
                      <td className="px-6 py-4 text-sm font-medium">
                        {formatDate(item.OpenedAt)}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-400">
                        {item.ClosedAt ? formatDate(item.ClosedAt) : "-"}
                      </td>
                      <td className="px-6 py-4 text-right font-mono text-sm">
                        {formatCurrency(item.OpeningCash)}
                      </td>
                      <td className="px-6 py-4 text-right font-mono text-sm">
                        {item.ClosingCash
                          ? formatCurrency(item.ClosingCash)
                          : "-"}
                      </td>
                      <td
                        className={`px-6 py-4 text-right font-black font-mono text-sm ${!item.Difference ? "text-gray-500" : item.Difference === 0 ? "text-green-500" : "text-red-500"}`}
                      >
                        {item.Difference !== undefined &&
                        item.Difference !== null
                          ? formatCurrency(item.Difference)
                          : "-"}
                      </td>
                      <td className="px-6 py-4 text-center">
                        <span
                          className={`px-3 py-1 rounded-full text-[10px] font-black tracking-widest uppercase border ${item.Status === "open" ? "bg-green-500/10 text-green-500 border-green-500/20" : "bg-gray-800 text-gray-500 border-white/5"}`}
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

          {totalPages > 1 && (
            <div className="px-6 py-4 border-t border-white/5 flex justify-between items-center bg-white/5">
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page === 1}
              >
                Prev
              </Button>
              <span className="text-xs font-black text-gray-500 uppercase tracking-widest">
                Hal {page} / {totalPages}
              </span>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
              >
                Next
              </Button>
            </div>
          )}
        </Card>
      </div>
    </div>
  );
}
