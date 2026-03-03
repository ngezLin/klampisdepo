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
    `flex items-center gap-2 p-2 rounded-lg transition-all relative ${
      isActive
        ? "bg-blue-600/10 text-blue-400 font-semibold border-l-[3px] border-blue-500 pl-3"
        : "text-gray-400 hover:bg-white/5 hover:text-white"
    }`;

  return (
    <>
      {/* Toggle button visible on mobile */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        aria-label="Buka menu navigasi"
        className="md:hidden fixed top-3 left-3 z-50 bg-gray-800 text-white p-2 rounded-lg shadow-md hover:bg-gray-700 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500"
      >
        <Menu className="w-5 h-5" />
      </button>

      {/* Overlay (mobile) */}
      {isOpen && (
        <div
          onClick={() => setIsOpen(false)}
          className="fixed inset-0 bg-black bg-opacity-40 z-40 md:hidden"
        />
      )}

      {/* Sidebar */}
      <aside
        className={`fixed top-0 left-0 h-screen z-50 bg-gray-800 text-white flex flex-col transition-all duration-300
          ${isCollapsed ? "w-20" : "w-64"}
          ${isOpen ? "translate-x-0" : "-translate-x-full"} md:translate-x-0
        `}
      >
        <button
          onClick={() =>
            window.innerWidth >= 768 ? handleCollapse() : setIsOpen(false)
          }
          className="flex items-center justify-center bg-gray-900 hover:bg-gray-800 text-white font-black text-xs uppercase tracking-[0.2em] py-5 border-b border-white/5 transition-all"
        >
          {isCollapsed ? (
            <Menu className="w-5 h-5 flex-shrink-0" />
          ) : (
            <div className="flex items-center gap-2 px-4 w-full">
              <div className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center">
                <LayoutDashboard className="w-5 h-5 text-white" />
              </div>
              <span className="font-black text-white whitespace-nowrap">
                KLAMPIS DEPO
              </span>
              <ChevronLeft className="ml-auto w-4 h-4 opacity-30 group-hover:opacity-100 hidden md:block" />
            </div>
          )}
        </button>

        {/* Navigation Links */}
        <div className="flex-1 overflow-y-auto pt-4 p-4 flex flex-col justify-between">
          <div>
            <nav className="space-y-2">
              {navigationItems.map((item) => {
                if (item.roles && !item.roles.includes(role)) return null;
                return (
                  <NavLink key={item.path} to={item.path} className={linkClass}>
                    {item.icon}
                    {!isCollapsed && item.label}
                  </NavLink>
                );
              })}
            </nav>
          </div>

          {/* Bottom User Info + Logout */}
          <div className="space-y-2">
            {role && (
              <div
                className={`flex items-center gap-3 p-3 bg-white/5 border border-white/5 rounded-2xl transition-all ${isCollapsed ? "justify-center px-0" : ""}`}
              >
                <div className="w-10 h-10 rounded-xl bg-blue-600/20 flex items-center justify-center text-blue-400 flex-shrink-0">
                  <UserCircle className="w-6 h-6" />
                </div>
                {!isCollapsed && (
                  <div className="flex flex-col min-w-0">
                    <span className="text-[10px] font-black text-blue-500 uppercase tracking-widest leading-none mb-1">
                      {role === "owner" ? "Boss" : "Staff"}
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
              className={`w-full ${isCollapsed ? "px-0 justify-center" : "justify-start"} mt-2`}
            >
              {!isCollapsed && "Logout"}
            </Button>
          </div>
        </div>
      </aside>
    </>
  );
}
