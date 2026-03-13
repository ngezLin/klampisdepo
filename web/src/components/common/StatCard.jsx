import React from "react";
import Card from "./Card";
import { motion } from "framer-motion";

export default function StatCard({
  label,
  value,
  icon: Icon,
  colorClass = "text-blue-400",
  trend,
  className = "",
  delay = 0,
}) {
  return (
    <Card className={`group ${className}`} delay={delay}>
      <div className="flex items-start justify-between">
        <div className="space-y-1">
          <p className="text-[10px] font-black text-slate-500 uppercase tracking-[0.2em]">
            {label}
          </p>
          <h2 className="text-2xl font-black text-white tabular-nums tracking-tight">
            {value}
          </h2>
          {trend && (
            <div
              className={`text-xs font-bold flex items-center gap-1 mt-1 ${trend.positive ? "text-emerald-400" : "text-rose-400"}`}
            >
              <span>{trend.positive ? "↑" : "↓"}</span>
              <span>{trend.value}</span>
            </div>
          )}
        </div>
        <div
          className={`p-3.5 rounded-2xl bg-white/[0.03] border border-white/[0.05] group-hover:bg-white/[0.06] transition-all duration-200 ${colorClass}`}
        >
          {Icon && <Icon className="w-6 h-6 stroke-[2.5px]" />}
        </div>
      </div>
    </Card>
  );
}
