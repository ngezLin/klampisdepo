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
  PieChart,
  Pie,
  Legend,
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
  ArrowUpRight,
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
      <div className="p-4 sm:p-6 lg:p-10 space-y-10 min-h-screen">
        <div className="flex flex-col gap-2">
          <Skeleton
            variant="text"
            width={240}
            height={48}
            sx={{ bgcolor: "rgba(255,255,255,0.03)", borderRadius: "8px" }}
          />
          <Skeleton
            variant="text"
            width={340}
            height={24}
            sx={{ bgcolor: "rgba(255,255,255,0.03)", borderRadius: "4px" }}
          />
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {[...Array(6)].map((_, i) => (
            <Skeleton
              key={i}
              variant="rounded"
              height={140}
              sx={{ bgcolor: "rgba(255,255,255,0.03)", borderRadius: "24px" }}
            />
          ))}
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <Skeleton
            variant="rounded"
            height={440}
            sx={{ bgcolor: "rgba(255,255,255,0.03)", borderRadius: "24px" }}
          />
          <Skeleton
            variant="rounded"
            height={440}
            sx={{ bgcolor: "rgba(255,255,255,0.03)", borderRadius: "24px" }}
          />
        </div>
      </div>
    );
  }

  const COLORS = ["#3b82f6", "#10b981", "#f59e0b", "#ef4444", "#8b5cf6"];
  const PIE_COLORS = ["#10b981", "#334155"];

  const monthlyCost = Math.max(0, data.monthly_omzet - data.monthly_profit);
  const pieData = [
    { name: "Profit", value: data.monthly_profit },
    { name: "Cost", value: monthlyCost },
  ];

  return (
    <div className="p-4 sm:p-6 lg:p-10 min-h-screen max-w-7xl mx-auto overflow-hidden">
      <div className="mb-12 flex flex-col md:flex-row md:items-end md:justify-between gap-6">
        <div>
          <div className="flex items-center gap-4 mb-2">
            <div className="p-2.5 rounded-xl bg-blue-600/10 border border-blue-500/20">
              <LayoutDashboard className="w-8 h-8 text-blue-500" />
            </div>
            <h1 className="text-4xl font-black text-white tracking-tight">
              Dashboard
            </h1>
          </div>
          <p className="text-slate-500 font-medium italic">
            Selamat datang kembali. Ringkasan performa bisnis Anda hari ini.
          </p>
        </div>
        
        <div className="flex items-center gap-3">
          <div className="px-4 py-2 rounded-xl bg-white/[0.03] border border-white/[0.05] text-xs font-bold text-slate-400 flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
            Live Updates
          </div>
        </div>
      </div>

      {/* SUMMARY CARDS */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
        <StatCard
          label="Omzet Hari Ini"
          value={formatCurrency(data.today_omzet)}
          icon={Coins}
          colorClass="text-blue-400"
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
          colorClass="text-indigo-400"
        />
        <StatCard
          label="Stok Menipis"
          value={data.low_stock}
          icon={AlertCircle}
          colorClass="text-rose-400"
          className={data.low_stock > 0 ? "border-rose-500/30 bg-rose-500/5 shadow-[0_0_20px_rgba(244,63,94,0.1)]" : ""}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-10">
        <Card
          title="Barang Terlaris"
          subtitle="Top 5 items berdasarkan kuantitas"
          headerAction={
             <button className="text-[10px] font-bold text-blue-500 uppercase tracking-widest hover:text-blue-400 transition-colors flex items-center gap-1">
               Lihat Detail <ArrowUpRight className="w-3 h-3" />
             </button>
          }
        >
          <div className="h-80 w-full mt-6">
            {data.top_selling_items?.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart
                  layout="vertical"
                  data={data.top_selling_items}
                  margin={{ top: 0, right: 30, left: 20, bottom: 0 }}
                >
                  <XAxis type="number" hide />
                  <YAxis
                    dataKey="name"
                    type="category"
                    width={100}
                    stroke="#64748b"
                    fontSize={12}
                    fontWeight={600}
                    tickLine={false}
                    axisLine={false}
                  />
                  <Tooltip
                    cursor={{ fill: "rgba(255, 255, 255, 0.05)", radius: 10 }}
                    contentStyle={{
                      borderRadius: "20px",
                      border: "1px solid rgba(255,255,255,0.1)",
                      backgroundColor: "rgba(15, 23, 42, 0.9)",
                      backdropFilter: "blur(10px)",
                      color: "#f3f4f6",
                      boxShadow: "0 20px 25px -5px rgba(0, 0, 0, 0.5)",
                      fontSize: "12px",
                      fontWeight: 700,
                      padding: "12px 16px",
                    }}
                    formatter={(value) => [value, "Terjual"]}
                  />
                  <Bar
                    dataKey="quantity"
                    name="Quantity"
                    radius={[0, 8, 8, 0]}
                    barSize={20}
                  >
                    {data.top_selling_items.map((entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={COLORS[index % COLORS.length]}
                        fillOpacity={0.9}
                      />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <div className="flex flex-col items-center justify-center h-full text-slate-600 space-y-3 italic">
                <div className="p-4 rounded-full bg-slate-900 border border-white/5">
                  <Package className="w-10 h-10 opacity-30" />
                </div>
                <p className="text-sm font-medium">Belum ada data penjualan tercatat</p>
              </div>
            )}
          </div>
        </Card>

        <Card 
          title="Peforma Penjualan" 
          subtitle="Profit vs Biaya (Bulan Ini)" 
        >
          <div className="h-80 w-full mt-6">
            {data.monthly_omzet > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={pieData}
                    cx="50%"
                    cy="45%"
                    innerRadius={60}
                    outerRadius={90}
                    paddingAngle={5}
                    dataKey="value"
                    stroke="none"
                  >
                    {pieData.map((entry, index) => (
                      <Cell 
                        key={`cell-${index}`} 
                        fill={PIE_COLORS[index % PIE_COLORS.length]} 
                        className="hover:opacity-80 transition-opacity"
                      />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      borderRadius: "20px",
                      border: "1px solid rgba(255,255,255,0.1)",
                      backgroundColor: "rgba(15, 23, 42, 0.9)",
                      backdropFilter: "blur(10px)",
                      color: "#f3f4f6",
                      fontSize: "12px",
                      fontWeight: 700,
                      padding: "12px 16px",
                    }}
                    formatter={(value) => [formatCurrency(value), ""]}
                  />
                  <Legend 
                    verticalAlign="bottom" 
                    align="center"
                    iconType="circle"
                    formatter={(value) => (
                      <span className="text-slate-400 font-bold text-xs uppercase tracking-wider ml-2">
                        {value}
                      </span>
                    )}
                  />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex flex-col items-center justify-center bg-white/[0.02] rounded-3xl border border-white/[0.05] border-dashed group hover:bg-white/[0.04] transition-all duration-500">
                <div className="text-center">
                  <div className="w-16 h-16 rounded-3xl bg-slate-900 flex items-center justify-center mx-auto mb-4 border border-white/5 group-hover:scale-110 transition-transform duration-500">
                    <TrendingUp className="w-8 h-8 text-slate-600" />
                  </div>
                  <p className="text-slate-400 text-sm font-bold tracking-tight">
                    Grafik Riwayat Menunggu Data
                  </p>
                  <p className="text-slate-600 text-[10px] mt-1 font-medium">
                    Sistem akan menampilkan tren otomatis setelah transaksi diproses.
                  </p>
                </div>
              </div>
            )}
          </div>
        </Card>
      </div>
    </div>
  );
}
