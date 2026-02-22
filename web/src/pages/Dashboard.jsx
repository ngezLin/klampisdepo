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
} from "recharts";
import { motion } from "framer-motion";
import { toast } from "react-hot-toast";
import { Skeleton } from "@mui/material";
import { formatCurrency } from "../utils/format";

export default function Dashboard() {
  const [data, setData] = useState({
    top_selling_items: [],
    today_profit: 0,
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
      <div className="p-3 sm:p-5 lg:p-6 space-y-6">
        <Skeleton variant="text" width={200} height={40} />
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-4">
          {[...Array(4)].map((_, i) => (
            <Skeleton
              key={i}
              variant="rectangular"
              height={100}
              className="rounded shadow"
            />
          ))}
        </div>
        <Skeleton
          variant="rectangular"
          height={300}
          className="rounded shadow"
        />
      </div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      className="p-3 sm:p-5 lg:p-6"
    >
      <h1 className="text-xl sm:text-2xl font-bold mb-4 text-gray-800">
        Dashboard Overview
      </h1>

      {/* SUMMARY CARDS */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-4 mb-6">
        <DashboardCard
          title="Today's Profit"
          value={formatCurrency(data.today_profit)}
          color="bg-green-50"
          valueColor="text-green-600"
        />
        <DashboardCard
          title="Transactions Today"
          value={data.today_transactions}
          color="bg-blue-50"
          valueColor="text-blue-600"
        />
        <DashboardCard
          title="Low Stock (<5)"
          value={data.low_stock}
          color="bg-red-50"
          valueColor="text-red-600"
        />
      </div>

      {/* TOP SELLING ITEMS */}
      <section>
        <h2 className="text-lg sm:text-xl font-semibold mb-3 text-gray-800">
          Top 5 Selling Items
        </h2>
        <motion.div
          initial={{ scale: 0.95 }}
          animate={{ scale: 1 }}
          transition={{ duration: 0.3 }}
          className="bg-white p-3 sm:p-4 rounded shadow h-64 sm:h-72 md:h-80"
        >
          {data.top_selling_items.length > 0 ? (
            <ResponsiveContainer width="100%" height="100%">
              <BarChart
                layout="vertical"
                data={data.top_selling_items}
                margin={{ top: 10, right: 30, left: 0, bottom: 10 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" />
                <YAxis dataKey="name" type="category" width={100} />
                <Tooltip
                  formatter={(value) => [value, "Quantity"]}
                  cursor={{ fill: "transparent" }}
                />
                <Legend />
                <Bar
                  dataKey="quantity"
                  fill="#f59e0b"
                  name="Quantity Sold"
                  radius={[0, 4, 4, 0]}
                />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="flex items-center justify-center h-full text-gray-500">
              No top selling data available
            </div>
          )}
        </motion.div>
      </section>
    </motion.div>
  );
}

function DashboardCard({
  title,
  value,
  color = "bg-white",
  valueColor = "text-gray-800",
}) {
  return (
    <motion.div
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
      className={`${color} p-3 sm:p-4 rounded shadow text-center sm:text-left transition-colors duration-200`}
    >
      <p className="text-gray-500 text-xs sm:text-sm">{title}</p>
      <p
        className={`text-base sm:text-lg md:text-xl font-bold mt-1 ${valueColor}`}
      >
        {value}
      </p>
    </motion.div>
  );
}
