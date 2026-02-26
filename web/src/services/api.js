import axios from "axios";

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || "https://api.klampisdepo.com",
  // baseURL: process.env.REACT_APP_API_URL || "http://localhost:8080",
});

// Add request interceptor to attach token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");

  // JANGAN pasang token untuk endpoint login
  if (token && !config.url.includes("/login")) {
    config.headers.Authorization = `Bearer ${token}`;
  }

  return config;
});

// Add response interceptor for better error handling
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid
      localStorage.removeItem("token");
      localStorage.removeItem("role");
      window.location.href = "/login";
    }
    return Promise.reject(error);
  },
);

export default api;
