import React from "react";
import Card from "./Card";

export default function StatCard({
  label,
  value,
  icon: Icon,
  colorClass = "text-blue-400",
  trend,
  className = "",
}) {
  return (
    <Card className={`group hover:border-white/10 ${className}`}>
      <div className="flex items-start justify-between">
        <div className="space-y-1">
          <p className="text-xs font-bold text-gray-500 uppercase tracking-widest">
            {label}
          </p>
          <h2 className="text-2xl font-black text-white tabular-nums tracking-tight">
            {value}
          </h2>
          {trend && (
            <div
              className={`text-xs font-bold flex items-center gap-1 ${trend.positive ? "text-green-400" : "text-red-400"}`}
            >
              <span>{trend.positive ? "↑" : "↓"}</span>
              <span>{trend.value}</span>
            </div>
          )}
        </div>
        <div
          className={`p-3 rounded-xl bg-white/5 group-hover:bg-white/10 transition-colors ${colorClass}`}
        >
          {Icon && <Icon className="w-6 h-6" />}
        </div>
      </div>
    </Card>
  );
}
