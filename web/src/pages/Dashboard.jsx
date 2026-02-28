import { useEffect, useState } from "react";
import { getDashboard } from "../services/dashboard";
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  Cell,
} from "recharts";
import { motion } from "framer-motion";
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
} from "lucide-react";

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
        toast.error("Failed to load dashboard data");
      } finally {
        setLoading(false);
      }
    };
    fetchDashboard();
  }, []);

  if (loading) {
    return (
      <div className="p-4 sm:p-6 lg:p-8 space-y-8 bg-gray-50/50 min-h-screen">
        <Skeleton variant="text" width={240} height={50} />
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
          {[...Array(4)].map((_, i) => (
            <Skeleton
              key={i}
              variant="rounded"
              height={140}
              className="rounded-2xl shadow-sm"
            />
          ))}
        </div>
        <Skeleton
          variant="rounded"
          height={380}
          className="rounded-2xl shadow-sm"
        />
      </div>
    );
  }

  // Define colors for the bar chart
  const COLORS = ["#3b82f6", "#10b981", "#f59e0b", "#ef4444", "#8b5cf6"];

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, ease: "easeOut" }}
      className="p-4 sm:p-6 lg:p-8 bg-gray-50/50 min-h-[calc(100vh-64px)]"
    >
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-gray-900 tracking-tight">
            Dashboard Overview
          </h1>
          <p className="text-sm text-gray-500 mt-1">
            Here's what's happening with your business today.
          </p>
        </div>
      </div>

      {/* SUMMARY CARDS */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6 mb-8">
        <DashboardCard
          title="Daily Omzet"
          value={formatCurrency(data.today_omzet)}
          icon={Coins}
          gradient="from-fuchsia-500 to-pink-500"
          shadowColor="shadow-fuchsia-200"
          delay={0.1}
        />
        <DashboardCard
          title="Daily Profit"
          value={formatCurrency(data.today_profit)}
          icon={Wallet}
          gradient="from-emerald-500 to-teal-400"
          shadowColor="shadow-emerald-200"
          delay={0.2}
        />
        <DashboardCard
          title="Transactions Today"
          value={data.today_transactions}
          icon={TrendingUp}
          gradient="from-amber-500 to-orange-400"
          shadowColor="shadow-amber-200"
          delay={0.3}
        />
        <DashboardCard
          title="Monthly Omzet"
          value={formatCurrency(data.monthly_omzet)}
          icon={BadgeDollarSign}
          gradient="from-violet-500 to-purple-500"
          shadowColor="shadow-violet-200"
          delay={0.4}
        />
        <DashboardCard
          title="Monthly Profit"
          value={formatCurrency(data.monthly_profit)}
          icon={CalendarRange}
          gradient="from-blue-600 to-indigo-500"
          shadowColor="shadow-blue-200"
          delay={0.5}
        />
        <DashboardCard
          title="Low Stock Warning"
          value={data.low_stock}
          subtitle="Items < 5"
          icon={AlertCircle}
          gradient="from-rose-500 to-red-500"
          shadowColor="shadow-rose-200"
          delay={0.6}
        />
      </div>

      {/* TOP SELLING ITEMS */}
      <motion.section
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.5, ease: "easeOut" }}
      >
        <div className="flex items-center space-x-2 mb-6">
          <Package className="w-6 h-6 text-gray-700" />
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900">
            Top 5 Selling Items
          </h2>
        </div>

        <div className="bg-white p-4 sm:p-6 rounded-2xl shadow-sm border border-gray-100 h-[350px] sm:h-[400px]">
          {data.top_selling_items?.length > 0 ? (
            <ResponsiveContainer width="100%" height="100%">
              <BarChart
                layout="vertical"
                data={data.top_selling_items}
                margin={{ top: 10, right: 30, left: 0, bottom: 10 }}
              >
                <CartesianGrid
                  strokeDasharray="3 3"
                  horizontal={false}
                  stroke="#e5e7eb"
                />
                <XAxis
                  type="number"
                  stroke="#6b7280"
                  fontSize={12}
                  tickLine={false}
                  axisLine={false}
                />
                <YAxis
                  dataKey="name"
                  type="category"
                  width={140}
                  stroke="#374151"
                  fontSize={12}
                  fontWeight={500}
                  tickLine={false}
                  axisLine={false}
                />
                <Tooltip
                  cursor={{ fill: "#f3f4f6" }}
                  contentStyle={{
                    borderRadius: "12px",
                    border: "none",
                    boxShadow:
                      "0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)",
                    fontWeight: 500,
                  }}
                  formatter={(value) => [value, "Quantity Sold"]}
                />
                <Legend
                  iconType="circle"
                  wrapperStyle={{ paddingTop: "20px" }}
                />
                <Bar
                  dataKey="quantity"
                  name="Quantity Sold"
                  radius={[0, 8, 8, 0]}
                  barSize={32}
                >
                  {data.top_selling_items.map((entry, index) => (
                    <Cell
                      key={`cell-${index}`}
                      fill={COLORS[index % COLORS.length]}
                    />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="flex flex-col items-center justify-center h-full text-gray-400 space-y-3">
              <Package className="w-12 h-12 opacity-20" />
              <p className="font-medium">No top selling data available</p>
            </div>
          )}
        </div>
      </motion.section>
    </motion.div>
  );
}

function DashboardCard({
  title,
  value,
  subtitle,
  icon: Icon,
  gradient,
  shadowColor,
  delay = 0,
}) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.4, delay, ease: "easeOut" }}
      whileHover={{ y: -5, scale: 1.02 }}
      className={`relative overflow-hidden bg-gradient-to-br ${gradient} p-5 sm:p-6 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 ${shadowColor}`}
    >
      <div className="absolute -right-6 -top-6 opacity-20 transform rotate-12 transition-transform duration-500 hover:rotate-45">
        <Icon className="w-32 h-32 text-white" />
      </div>

      <div className="relative z-10">
        <div className="flex justify-between items-start mb-4">
          <p className="text-white/90 text-sm font-semibold tracking-wider uppercase text-shadow-sm">
            {title}
          </p>
          <div className="p-2 bg-white/20 rounded-xl backdrop-blur-md shadow-inner">
            <Icon className="w-6 h-6 text-white" />
          </div>
        </div>

        <div className="mt-2 text-white">
          <h3 className="text-3xl font-extrabold tracking-tight drop-shadow-md">
            {value}
          </h3>
          {subtitle ? (
            <p className="text-white/80 text-sm mt-2 font-medium">{subtitle}</p>
          ) : (
            <p className="text-white/80 text-sm mt-2 font-medium opacity-0">
              Placeholder
            </p> // Keeps height consistent
          )}
        </div>
      </div>
    </motion.div>
  );
}
