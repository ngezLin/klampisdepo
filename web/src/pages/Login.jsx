import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { login } from "../services/authService";
import { motion, AnimatePresence } from "framer-motion";
import { toast } from "react-hot-toast";
import { Lock, User, ArrowRight, Loader2 } from "lucide-react";

export default function Login() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const { user } = await login(username, password);
      toast.success(`Welcome back, ${user.username || "User"}!`);

      if (user.role === "admin") {
        navigate("/cash-sessions");
      } else if (user.role === "cashier") {
        navigate("/transactions");
      } else {
        navigate("/dashboard");
      }
    } catch (err) {
      toast.error(
        err.response?.data?.error ||
          "Login failed. Please check your credentials.",
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen w-full flex items-center justify-center bg-[#010101] overflow-hidden relative font-['Inter']">
      {/* Background Blobs */}
      <div className="absolute top-0 -left-4 w-72 h-72 bg-purple-600 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-blob"></div>
      <div className="absolute top-0 -right-4 w-72 h-72 bg-blue-600 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-blob animation-delay-2000"></div>
      <div className="absolute -bottom-8 left-20 w-72 h-72 bg-pink-600 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-blob animation-delay-4000"></div>

      {/* Floating Elements for extra depth */}
      <motion.div
        animate={{ y: [0, -10, 0], rotate: [0, 5, 0] }}
        transition={{ duration: 4, repeat: Infinity }}
        className="absolute top-1/4 left-1/4 w-12 h-12 border border-white/10 rounded-lg backdrop-blur-sm hidden lg:block"
      />
      <motion.div
        animate={{ y: [0, 15, 0], rotate: [0, -8, 0] }}
        transition={{ duration: 5, repeat: Infinity, delay: 1 }}
        className="absolute bottom-1/4 right-1/4 w-16 h-16 border border-white/10 rounded-full backdrop-blur-sm hidden lg:block"
      />

      <motion.div
        initial={{ opacity: 0, scale: 0.9, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="relative z-10 w-full max-w-md p-8 sm:p-10"
      >
        <div className="bg-white/10 backdrop-blur-xl border border-white/20 rounded-3xl shadow-[0_8px_32px_0_rgba(0,0,0,0.36)] p-8 sm:p-10 relative overflow-hidden group">
          {/* subtle shine effect */}
          <div className="absolute -inset-x-full top-0 h-full w-full bg-gradient-to-r from-transparent via-white/5 to-transparent skew-x-[-35deg] group-hover:transition-all group-hover:duration-1000 group-hover:translate-x-[200%]"></div>

          <div className="mb-10 text-center">
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
              className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-tr from-blue-600 to-purple-600 rounded-2xl shadow-lg mb-6 group-hover:rotate-12 transition-transform duration-500"
            >
              <Lock className="w-10 h-10 text-white" />
            </motion.div>
            <h1 className="text-3xl font-extrabold text-white tracking-tight mb-2">
              KlampisDepo
            </h1>
            <p className="text-gray-400 text-sm font-medium">
              Elevate your inventory management
            </p>
          </div>

          <form onSubmit={handleLogin} className="space-y-6">
            <div className="space-y-4">
              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <User className="h-5 w-5 text-gray-500 group-focus-within:text-blue-500 transition-colors" />
                </div>
                <input
                  type="text"
                  placeholder="Username"
                  autoComplete="username"
                  className="block w-full pl-11 pr-4 py-3.5 bg-black/30 border border-white/5 rounded-2xl text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500/50 transition-all text-sm font-medium"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  required
                />
              </div>

              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-gray-500 group-focus-within:text-purple-500 transition-colors" />
                </div>
                <input
                  type="password"
                  placeholder="Password"
                  autoComplete="current-password"
                  className="block w-full pl-11 pr-4 py-3.5 bg-black/30 border border-white/5 rounded-2xl text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-purple-500/50 focus:border-purple-500/50 transition-all text-sm font-medium"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
            </div>

            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              disabled={loading}
              className="w-full relative group overflow-hidden bg-gradient-to-r from-blue-600 to-purple-600 text-white font-bold py-4 rounded-2xl shadow-xl hover:shadow-blue-500/25 transition-all flex items-center justify-center gap-2"
            >
              <div className="absolute inset-0 bg-white/10 opacity-0 group-hover:opacity-100 transition-opacity" />
              {loading ? (
                <Loader2 className="w-5 h-5 animate-spin" />
              ) : (
                <>
                  <span>Sign In</span>
                  <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                </>
              )}
            </motion.button>
          </form>

          <p className="mt-8 text-center text-xs text-gray-500">
            Powered by KlampisDepo Engine V2
          </p>
        </div>
      </motion.div>
    </div>
  );
}
