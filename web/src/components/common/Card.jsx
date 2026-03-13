import React from "react";
import { motion } from "framer-motion";

export default function Card({
  children,
  title,
  subtitle,
  footer,
  className = "",
  headerAction,
  delay = 0,
}) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.3 }}
      className={`glass-card glass-card-hover rounded-2xl overflow-hidden ${className}`}
    >
      {(title || subtitle || headerAction) && (
        <div className="px-6 py-5 border-b border-white/[0.05] flex items-center justify-between bg-white/[0.01]">
          <div>
            {title && (
              <h3 className="text-lg font-bold text-white tracking-tight">
                {title}
              </h3>
            )}
            {subtitle && (
              <p className="text-sm text-slate-500 mt-1 font-medium">{subtitle}</p>
            )}
          </div>
          {headerAction && <div>{headerAction}</div>}
        </div>
      )}

      <div className="p-6">{children}</div>

      {footer && (
        <div className="px-6 py-4 bg-white/[0.02] border-t border-white/[0.05] text-slate-400 text-sm font-medium">
          {footer}
        </div>
      )}
    </motion.div>
  );
}
