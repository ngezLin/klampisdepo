import { useState } from "react";
import Sidebar from "./Sidebar";

export default function Layout({ children }) {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <div className="flex min-h-screen bg-gray-100 transition-all duration-300">
      <Sidebar onToggleCollapse={setCollapsed} />
      <main
        className={`flex-1 p-4 md:p-6 overflow-y-auto w-full transition-all duration-300
    ${collapsed ? "md:ml-20" : "md:ml-64"}
  `}
      >
        {children}
      </main>
    </div>
  );
}
