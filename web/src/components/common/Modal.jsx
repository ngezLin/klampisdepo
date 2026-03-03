import { motion, AnimatePresence } from "framer-motion";
import { X } from "lucide-react";

export default function Modal({
  isOpen,
  onClose,
  children,
  title,
  maxWidth = "max-w-lg",
}) {
  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          {/* Overlay */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="absolute inset-0 bg-black/80 backdrop-blur-sm"
            onClick={onClose}
          />

          {/* Content */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 10 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 10 }}
            transition={{ duration: 0.2, ease: "easeOut" }}
            className={`relative ${maxWidth} w-full bg-gray-900 border border-white/10 rounded-2xl shadow-2xl max-h-[90vh] overflow-y-auto`}
          >
            {/* Header */}
            {(title || onClose) && (
              <div className="flex items-center justify-between p-5 border-b border-white/5">
                {title && (
                  <h2 className="text-lg font-bold text-white">{title}</h2>
                )}
                {onClose && (
                  <button
                    onClick={onClose}
                    aria-label="Tutup modal"
                    className="p-1.5 rounded-lg text-gray-500 hover:text-white hover:bg-white/10 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500"
                  >
                    <X className="w-5 h-5" />
                  </button>
                )}
              </div>
            )}

            {/* Body */}
            <div className="p-5">{children}</div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
