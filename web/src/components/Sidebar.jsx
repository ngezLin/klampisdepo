import { useState } from "react";
import { NavLink, useNavigate } from "react-router-dom";
import { navigationItems } from "../config/navigation";
import { logout } from "../services/authService";
import {
  Menu,
  LogOut,
  UserCircle,
  ChevronLeft,
  LayoutDashboard,
} from "lucide-react";
import { motion } from "framer-motion";
import Button from "./common/Button";

export default function Sidebar({ onToggleCollapse }) {
  const navigate = useNavigate();
  const role = localStorage.getItem("role") || "user";
  const [isOpen, setIsOpen] = useState(false);
  const [isCollapsed, setIsCollapsed] = useState(false);

  // 🟢 Toggle collapse & kirim status ke parent (Layout)
  const handleCollapse = () => {
    const nextState = !isCollapsed;
    setIsCollapsed(nextState);
    if (onToggleCollapse) onToggleCollapse(nextState);
  };

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  const linkClass = ({ isActive }) =>
    `flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-300 group relative ${
      isActive
        ? "bg-blue-600/10 text-blue-400 font-bold"
        : "text-slate-400 hover:bg-white/[0.03] hover:text-white"
    }`;

  return (
    <>
      {/* Toggle button visible on mobile */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        aria-label="Buka menu navigasi"
        className="md:hidden fixed top-4 left-4 z-50 bg-slate-900/80 backdrop-blur-lg text-white p-2.5 rounded-xl border border-white/10 shadow-2xl hover:bg-slate-800 transition-all active:scale-95"
      >
        <Menu className="w-5 h-5" />
      </button>

      {/* Overlay (mobile) */}
      {isOpen && (
        <div
          onClick={() => setIsOpen(false)}
          className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40 md:hidden"
        />
      )}

      {/* Sidebar */}
      <aside
        className={`fixed top-0 left-0 h-screen z-50 bg-slate-950/50 backdrop-blur-2xl border-r border-white/5 flex flex-col transition-all duration-500 ease-[cubic-bezier(0.4,0,0.2,1)]
          ${isCollapsed ? "w-20" : "w-64"}
          ${isOpen ? "translate-x-0" : "-translate-x-full"} md:translate-x-0
        `}
      >
        <button
          onClick={() =>
            window.innerWidth >= 768 ? handleCollapse() : setIsOpen(false)
          }
          className="flex items-center justify-center py-8 border-b border-white/[0.03] group transition-all"
        >
          {isCollapsed ? (
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-blue-700 flex items-center justify-center shadow-lg shadow-blue-500/20">
              <LayoutDashboard className="w-5 h-5 text-white" />
            </div>
          ) : (
            <div className="flex items-center gap-3 px-6 w-full">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-blue-700 flex items-center justify-center shadow-lg shadow-blue-500/20 flex-shrink-0">
                <LayoutDashboard className="w-5 h-5 text-white" />
              </div>
              <div className="flex flex-col items-start overflow-hidden">
                <span className="font-black text-white text-lg tracking-tight whitespace-nowrap">
                  KLAMPIS DEPO
                </span>
                <span className="text-[10px] font-bold text-blue-500 uppercase tracking-[0.2em] leading-none">
                  Warehouse
                </span>
              </div>
              <ChevronLeft className="ml-auto w-4 h-4 opacity-30 group-hover:opacity-100 hidden md:block transition-opacity" />
            </div>
          )}
        </button>

        {/* Navigation Links */}
        <div className="flex-1 overflow-y-auto py-6 px-3 flex flex-col justify-between scrollbar-hide">
          <div>
            <nav className="space-y-1.5">
              {navigationItems.map((item) => {
                if (item.roles && !item.roles.includes(role)) return null;
                return (
                  <NavLink key={item.path} to={item.path} className={linkClass}>
                    {({ isActive }) => (
                      <>
                        <div className="transition-transform duration-200">
                          {item.icon}
                        </div>
                        {!isCollapsed && (
                          <span className="text-sm tracking-wide">{item.label}</span>
                        )}
                        {isActive && (
                          <div className="absolute left-0 w-1 h-6 bg-blue-500 rounded-r-full" />
                        )}
                      </>
                    )}
                  </NavLink>
                );
              })}
            </nav>
          </div>

          {/* Bottom User Info + Logout */}
          <div className="space-y-3 px-2">
            {role && (
              <div
                className={`flex items-center gap-3 p-3 bg-white/[0.03] border border-white/[0.05] rounded-2xl transition-all ${isCollapsed ? "justify-center px-0 bg-transparent border-transparent" : ""}`}
              >
                <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-slate-700 to-slate-800 flex items-center justify-center text-slate-300 flex-shrink-0 shadow-lg border border-white/5">
                  <UserCircle className="w-6 h-6" />
                </div>
                {!isCollapsed && (
                  <div className="flex flex-col min-w-0">
                    <span className="text-[10px] font-black text-blue-500 uppercase tracking-widest leading-none mb-1">
                      {role === "owner" ? "Administrator" : "Warehouse Staff"}
                    </span>
                    <span className="font-bold text-white truncate text-sm">
                      {role.charAt(0).toUpperCase() + role.slice(1)}
                    </span>
                  </div>
                )}
              </div>
            )}

            <Button
              variant="danger"
              size="md"
              icon={LogOut}
              onClick={handleLogout}
              className={`w-full ${isCollapsed ? "p-0 rounded-xl justify-center h-12" : "rounded-2xl h-12 justify-center"} bg-rose-500/10 border-rose-500/20 text-rose-500 hover:bg-rose-500 hover:text-white transition-all duration-300`}
            >
              {!isCollapsed && "Keluar Akun"}
            </Button>
          </div>
        </div>
      </aside>
    </>
  );
}
