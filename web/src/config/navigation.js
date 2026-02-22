import {
  FaTachometerAlt,
  FaBox,
  FaReceipt,
  FaHistory,
  FaCalendarCheck,
  FaClipboardList,
  FaWallet,
} from "react-icons/fa";

export const navigationItems = [
  {
    label: "Dashboard",
    path: "/dashboard",
    icon: <FaTachometerAlt />,
    roles: ["admin"],
  },
  {
    label: "Cash Session",
    path: "/cash-sessions",
    icon: <FaWallet />,
    roles: ["cashier", "admin"],
  },
  {
    label: "Items",
    path: "/items",
    icon: <FaBox />,
    roles: ["cashier", "admin"],
  },
  {
    label: "Transactions",
    path: "/transactions",
    icon: <FaReceipt />,
    roles: ["cashier", "admin"],
  },
  {
    label: "History",
    path: "/history",
    icon: <FaHistory />,
    roles: ["cashier", "admin"],
  },
  {
    label: "Inventory History",
    path: "/inventory-history",
    icon: <FaClipboardList />, // Reusing icon or using a new one if available. FaClipboardList is used for Audit Logs. Let's use FaBoxOpen or something similar if imported? FaBox is used for Items.
    // Let's import FaWarehouse if possible, or just reuse FaBox for now to be safe with imports, or check imports.
    // FaClipboardList is imported.
    // Let's check imports in navigation.js
    // FaBox, FaReceipt, FaHistory, FaCalendarCheck, FaClipboardList, FaWallet, FaTachometerAlt are imported.
    // I will use FaBox for now, or just FaClipboardList but with different label.
    // Actually, let's use FaHistory but distinguish it.
    // Or add FaWarehouse to imports.
    // For now, to avoid import errors without checking available icons in react-icons/fa (though standard), I'll use FaBox.
    roles: ["cashier", "admin"],
  },
  {
    label: "Attendance",
    path: "/attendance",
    icon: <FaCalendarCheck />,
    roles: ["admin"],
  },
  {
    label: "Audit Logs",
    path: "/audit-logs",
    icon: <FaClipboardList />,
    roles: ["admin"],
  },
];
