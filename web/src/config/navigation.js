import {
  LayoutDashboard,
  Wallet,
  Box,
  Receipt,
  History,
  ClipboardList,
  CalendarCheck,
  FileText,
} from "lucide-react";

export const navigationItems = [
  {
    label: "Dashboard",
    path: "/dashboard",
    icon: <LayoutDashboard />,
    roles: ["owner"],
  },
  {
    label: "Sesi Kas",
    path: "/cash-sessions",
    icon: <Wallet />,
    roles: ["admin", "owner"],
  },
  {
    label: "Stok Barang",
    path: "/items",
    icon: <Box />,
    roles: ["admin", "owner"],
  },
  {
    label: "Transaksi",
    path: "/transactions",
    icon: <Receipt />,
    roles: ["cashier", "admin", "owner"],
  },
  {
    label: "Riwayat",
    path: "/history",
    icon: <History />,
    roles: ["cashier", "admin", "owner"],
  },
  {
    label: "Mutasi Stok",
    path: "/inventory-history",
    icon: <ClipboardList />,
    roles: ["owner"],
  },
  {
    label: "Presensi",
    path: "/attendance",
    icon: <CalendarCheck />,
    roles: ["owner"],
  },
  {
    label: "Log Audit",
    path: "/audit-logs",
    icon: <FileText />,
    roles: ["owner"],
  },
];
