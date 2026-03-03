import { useEffect, useState } from "react";
import { getDashboard } from "../services/dashboard";
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  Cell,
} from "recharts";
import { toast } from "react-hot-toast";
import { Skeleton } from "@mui/material";
import { formatCurrency } from "../utils/format";
import {
  TrendingUp,
  Wallet,
  Package,
  AlertCircle,
  CalendarRange,
  Coins,
  BadgeDollarSign,
  LayoutDashboard,
} from "lucide-react";
import StatCard from "../components/common/StatCard";
import Card from "../components/common/Card";

export default function Dashboard() {
  const [data, setData] = useState({
    top_selling_items: [],
    today_profit: 0,
    monthly_profit: 0,
    today_omzet: 0,
    monthly_omzet: 0,
    today_transactions: 0,
    low_stock: 0,
  });

  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDashboard = async () => {
      try {
        const res = await getDashboard();
        setData({
          ...res,
          top_selling_items: res.top_selling_items || [],
        });
      } catch (err) {
        console.error("Error fetching dashboard:", err);
        toast.error("Gagal mengambil data dashboard");
      } finally {
        setLoading(false);
      }
    };
    fetchDashboard();
  }, []);

  if (loading) {
    return (
      <div className="p-4 sm:p-6 lg:p-8 space-y-8 bg-[#0a0a0a] min-h-screen">
        <div className="flex flex-col gap-2">
          <Skeleton
            variant="text"
            width={240}
            height={40}
            sx={{ bgcolor: "rgba(255,255,255,0.05)" }}
          />
          <Skeleton
            variant="text"
            width={340}
            height={20}
            sx={{ bgcolor: "rgba(255,255,255,0.05)" }}
          />
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
          {[...Array(6)].map((_, i) => (
            <Skeleton
              key={i}
              variant="rounded"
              height={120}
              sx={{ bgcolor: "rgba(255,255,255,0.05)", borderRadius: "16px" }}
            />
          ))}
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Skeleton
            variant="rounded"
            height={400}
            sx={{ bgcolor: "rgba(255,255,255,0.05)", borderRadius: "16px" }}
          />
          <Skeleton
            variant="rounded"
            height={400}
            sx={{ bgcolor: "rgba(255,255,255,0.05)", borderRadius: "16px" }}
          />
        </div>
      </div>
    );
  }

  const COLORS = ["#3b82f6", "#10b981", "#f59e0b", "#ef4444", "#8b5cf6"];

  return (
    <div className="p-4 sm:p-6 lg:p-8 bg-[#0a0a0a] min-h-screen max-w-7xl mx-auto animate-in fade-in duration-700">
      <div className="mb-10">
        <h1 className="text-3xl font-black text-white tracking-tight flex items-center gap-3">
          <LayoutDashboard className="w-8 h-8 text-blue-500" />
          Dashboard
        </h1>
        <p className="text-gray-500 mt-1 font-medium italic">
          Selamat datang kembali. Ringkasan performa bisnis Anda hari ini.
        </p>
      </div>

      {/* SUMMARY CARDS */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6 mb-10">
        <StatCard
          label="Omzet Hari Ini"
          value={formatCurrency(data.today_omzet)}
          icon={Coins}
          colorClass="text-fuchsia-400"
        />
        <StatCard
          label="Profit Hari Ini"
          value={formatCurrency(data.today_profit)}
          icon={Wallet}
          colorClass="text-emerald-400"
        />
        <StatCard
          label="Transaksi Hari Ini"
          value={`${data.today_transactions} Trx`}
          icon={TrendingUp}
          colorClass="text-amber-400"
        />
        <StatCard
          label="Omzet Bulan Ini"
          value={formatCurrency(data.monthly_omzet)}
          icon={BadgeDollarSign}
          colorClass="text-violet-400"
        />
        <StatCard
          label="Profit Bulan Ini"
          value={formatCurrency(data.monthly_profit)}
          icon={CalendarRange}
          colorClass="text-blue-400"
        />
        <StatCard
          label="Stok Menipis"
          value={data.low_stock}
          icon={AlertCircle}
          colorClass="text-rose-400"
          className={data.low_stock > 0 ? "border-red-500/20" : ""}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <Card
          title="Barang Terlaris"
          subtitle="Top 5 items berdasarkan kuantitas"
        >
          <div className="h-80 w-full mt-4">
            {data.top_selling_items?.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart
                  layout="vertical"
                  data={data.top_selling_items}
                  margin={{ top: 0, right: 30, left: 10, bottom: 0 }}
                >
                  <XAxis type="number" hide />
                  <YAxis
                    dataKey="name"
                    type="category"
                    width={100}
                    stroke="#9ca3af"
                    fontSize={11}
                    fontWeight={600}
                    tickLine={false}
                    axisLine={false}
                  />
                  <Tooltip
                    cursor={{ fill: "rgba(255, 255, 255, 0.03)" }}
                    contentStyle={{
                      borderRadius: "16px",
                      border: "1px solid rgba(255,255,255,0.1)",
                      backgroundColor: "#111827",
                      color: "#f3f4f6",
                      boxShadow: "0 20px 25px -5px rgba(0, 0, 0, 0.5)",
                      fontSize: "12px",
                      fontWeight: 600,
                    }}
                    formatter={(value) => [value, "Terjual"]}
                  />
                  <Bar
                    dataKey="quantity"
                    name="Quantity"
                    radius={[0, 4, 4, 0]}
                    barSize={24}
                  >
                    {data.top_selling_items.map((entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={COLORS[index % COLORS.length]}
                        fillOpacity={0.8}
                      />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <div className="flex flex-col items-center justify-center h-full text-gray-600 space-y-2 italic">
                <Package className="w-8 h-8 opacity-20" />
                <p className="text-sm">Belum ada data penjualan</p>
              </div>
            )}
          </div>
        </Card>

        <Card title="Peforma Penjualan" subtitle="Visualisasi metrik utama">
          <div className="h-80 w-full mt-4 flex items-center justify-center bg-white/5 rounded-xl border border-white/5 border-dashed">
            <div className="text-center">
              <TrendingUp className="w-10 h-10 text-gray-700 mx-auto mb-2" />
              <p className="text-gray-500 text-sm font-medium">
                Grafik riwayat sedang disiapkan
              </p>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}
