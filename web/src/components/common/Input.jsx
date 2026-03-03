import { motion } from "framer-motion";

export default function Input({
  label,
  icon: Icon,
  type = "text",
  error,
  className = "",
  containerClassName = "",
  ...props
}) {
  return (
    <div className={`space-y-1.5 ${containerClassName}`}>
      {label && (
        <label className="block text-sm font-semibold text-gray-300 ml-1">
          {label}
        </label>
      )}
      <div className="relative group">
        {Icon && (
          <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
            <Icon className="h-5 w-5 text-gray-500 group-focus-within:text-blue-500 transition-colors" />
          </div>
        )}
        <input
          type={type}
          className={`
            block w-full ${Icon ? "pl-11" : "pl-4"} pr-4 py-3 bg-white/5 border 
            ${error ? "border-red-500/50" : "border-white/10"} 
            rounded-2xl text-white placeholder-gray-500 
            focus:outline-none focus:ring-2 
            ${error ? "focus:ring-red-500/30 focus:border-red-500/50" : "focus:ring-blue-500/30 focus:border-blue-500/50"} 
            transition-all text-sm font-medium
            disabled:opacity-50 disabled:cursor-not-allowed
            ${className}
          `}
          {...props}
        />
      </div>
      {error && (
        <motion.p
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-red-400 text-xs font-medium ml-1"
        >
          {error}
        </motion.p>
      )}
    </div>
  );
}
