import { useState } from "react";
import { NavLink, useNavigate } from "react-router-dom";
import { navigationItems } from "../config/navigation";
import { logout } from "../services/authService";
import {
  FaSignOutAlt,
  FaUserCircle,
  FaBars,
  FaAngleLeft,
} from "react-icons/fa";

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
    `flex items-center gap-2 p-2 rounded ${
      isActive ? "bg-gray-700 font-semibold" : "hover:bg-gray-700"
    }`;

  return (
    <>
      {/* Toggle button visible on mobile */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="md:hidden fixed top-3 left-3 z-50 bg-gray-800 text-white p-2 rounded-md shadow-md"
      >
        <FaBars />
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
    ${isCollapsed ? "md:w-20" : "md:w-64"}
    ${isOpen ? "translate-x-0 w-64" : "-translate-x-full w-64"} md:translate-x-0
  `}
      >
        {/* Header / Toggle collapse */}
        <button
          onClick={handleCollapse}
          className="flex items-center justify-center bg-gray-900 hover:bg-gray-700 text-white font-bold text-lg tracking-wide py-4 transition-all"
        >
          {isCollapsed ? (
            <FaBars className="text-xl" />
          ) : (
            <>
              <span className="ml-2">Klampis Depo</span>
              <FaAngleLeft className="ml-3 text-sm opacity-70" />
            </>
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
              <div className="flex items-center gap-2 p-2 bg-gray-700 rounded">
                <FaUserCircle className="text-xl" />
                {!isCollapsed && (
                  <div className="flex flex-col">
                    <span className="text-xs text-gray-400">Logged in as</span>
                    <span className="font-semibold capitalize">{role}</span>
                  </div>
                )}
              </div>
            )}

            <button
              onClick={handleLogout}
              className="flex items-center justify-center gap-2 w-full bg-red-500 hover:bg-red-600 text-white p-2 rounded transition-colors"
            >
              <FaSignOutAlt /> {!isCollapsed && "Logout"}
            </button>
          </div>
        </div>
      </aside>
    </>
  );
}
