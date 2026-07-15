import {
  LayoutDashboard,
  Wallet,
  Box,
  History,
  CalendarCheck,
  FileText,
  CalendarClock,
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
    label: "Tagihan PO",
    path: "/po-bills",
    icon: <CalendarClock />,
    roles: ["admin", "owner"],
  },
  {
    label: "Riwayat",
    path: "/history",
    icon: <History />,
    roles: ["admin", "owner"],
  },
  {
    label: "Mutasi Stok",
    path: "/logs",
    icon: <FileText />,
    roles: ["owner"],
  },
  {
    label: "Presensi",
    path: "/attendance",
    icon: <CalendarCheck />,
    roles: ["owner"],
  },
];
