import { motion } from "framer-motion";
import { Loader2 } from "lucide-react";

const variants = {
  primary:
    "bg-blue-600 hover:bg-blue-700 text-white shadow-lg shadow-blue-600/20 focus-visible:ring-blue-500",
  success:
    "bg-green-600 hover:bg-green-700 text-white shadow-lg shadow-green-600/20 focus-visible:ring-green-500",
  danger:
    "bg-red-600 hover:bg-red-700 text-white shadow-lg shadow-red-600/20 focus-visible:ring-red-500",
  warning:
    "bg-yellow-500 hover:bg-yellow-600 text-white shadow-lg shadow-yellow-500/20 focus-visible:ring-yellow-500",
  ghost:
    "bg-gray-800 hover:bg-gray-700 text-gray-300 border border-white/10 focus-visible:ring-gray-500",
  purple:
    "bg-purple-600 hover:bg-purple-700 text-white shadow-lg shadow-purple-600/20 focus-visible:ring-purple-500",
};

const sizes = {
  sm: "px-3 py-1.5 text-xs rounded-lg",
  md: "px-4 py-2 text-sm rounded-xl",
  lg: "px-5 py-3 text-sm rounded-xl",
};

export default function Button({
  children,
  variant = "primary",
  size = "md",
  icon: Icon,
  loading = false,
  disabled = false,
  className = "",
  ...props
}) {
  const isDisabled = disabled || loading;

  return (
    <motion.button
      whileTap={!isDisabled ? { scale: 0.96 } : undefined}
      disabled={isDisabled}
      className={`
        inline-flex items-center justify-center gap-2 font-bold
        transition-all duration-200
        focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-950
        ${variants[variant] || variants.primary}
        ${sizes[size] || sizes.md}
        ${isDisabled ? "opacity-50 cursor-not-allowed" : "active:scale-95"}
        ${className}
      `}
      {...props}
    >
      {loading ? (
        <Loader2 className="w-4 h-4 animate-spin" />
      ) : Icon ? (
        <Icon className="w-4 h-4" />
      ) : null}
      {children}
    </motion.button>
  );
}
