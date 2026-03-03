import React from "react";

export default function Card({
  children,
  title,
  subtitle,
  footer,
  className = "",
  headerAction,
}) {
  return (
    <div
      className={`bg-gray-900/50 backdrop-blur-sm border border-white/5 rounded-2xl shadow-xl overflow-hidden transition-all duration-300 ${className}`}
    >
      {(title || subtitle || headerAction) && (
        <div className="px-6 py-4 border-b border-white/5 flex items-center justify-between">
          <div>
            {title && (
              <h3 className="text-lg font-bold text-white tracking-tight">
                {title}
              </h3>
            )}
            {subtitle && (
              <p className="text-sm text-gray-500 mt-0.5">{subtitle}</p>
            )}
          </div>
          {headerAction && <div>{headerAction}</div>}
        </div>
      )}

      <div className="p-6">{children}</div>

      {footer && (
        <div className="px-6 py-4 bg-white/5 border-t border-white/5 text-gray-400 text-sm">
          {footer}
        </div>
      )}
    </div>
  );
}
