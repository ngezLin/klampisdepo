import React, { useState, useEffect, useRef } from "react";
import { ChevronDown, Check, Search, X } from "lucide-react";

/**
 * A reusable select component with search functionality.
 *
 * @param {Object} props
 * @param {Array} props.options - Array of objects with { id, name }
 * @param {string|number} props.value - Currently selected value (id)
 * @param {function} props.onChange - Callback when value changes
 * @param {function} props.onSearch - Callback for search input change
 * @param {string} props.selectedLabel - Label of selected item if not in options
 * @param {string} props.placeholder - Placeholder text
 * @param {string} props.label - Label text
 * @param {string} props.className - Additional classes
 * @param {boolean} props.disabled - Whether the select is disabled
 */
const SearchableSelect = ({
  options = [],
  value,
  onChange,
  onSearch,
  selectedLabel,
  placeholder = "Select...",
  label,
  className = "",
  disabled = false,
  onLoadMore,
  hasMore = false,
  loadingMore = false,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [filteredOptions, setFilteredOptions] = useState(options);
  const wrapperRef = useRef(null);
  const inputRef = useRef(null);

  // Find selected option object or use selectedLabel
  const selectedOption = options.find((opt) => opt.id === value);
  const displayLabel = selectedOption
    ? selectedOption.name
    : selectedLabel || placeholder;

  // Determine which options to display: local filtered or raw options (if server-side search)
  // If onSearch is provided, we assume the parent handles filtering and passes updated options.
  // If no onSearch, we filter locally.
  const displayOptions = onSearch ? options : filteredOptions;

  // Local filtering effect
  useEffect(() => {
    if (!onSearch) {
      setFilteredOptions(
        options.filter((opt) =>
          opt.name.toLowerCase().includes(searchTerm.toLowerCase()),
        ),
      );
    }
  }, [searchTerm, options, onSearch]);

  // Server-side search trigger effect
  useEffect(() => {
    if (onSearch) {
      const timer = setTimeout(() => {
        onSearch(searchTerm);
      }, 300); // Debounce search
      return () => clearTimeout(timer);
    }
  }, [searchTerm, onSearch]);

  // Handle click outside to close dropdown
  useEffect(() => {
    function handleClickOutside(event) {
      if (wrapperRef.current && !wrapperRef.current.contains(event.target)) {
        setIsOpen(false);
        setSearchTerm(""); // Reset search on close
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  // Autofocus input when opened
  useEffect(() => {
    if (isOpen && inputRef.current) {
      inputRef.current.focus();
    }
  }, [isOpen]);

  const handleSelect = (option) => {
    onChange(option.id);
    setIsOpen(false);
    setSearchTerm("");
  };

  const handleClear = (e) => {
    e.stopPropagation();
    onChange("");
  };

  return (
    <div
      className={`relative ${isOpen ? "z-50" : "z-0"} ${className}`}
      ref={wrapperRef}
    >
      {label && (
        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-2 ml-1">
          {label}
        </label>
      )}

      {/* Trigger Button */}
      <div
        className={`
          w-full bg-gray-800 border rounded-xl px-4 py-2.5 flex items-center justify-between cursor-pointer transition-all duration-200
          ${disabled ? "opacity-50 cursor-not-allowed bg-gray-900" : "hover:border-blue-500/50 hover:bg-gray-800/80"}
          ${isOpen ? "border-blue-500/50 ring-2 ring-blue-500/20 bg-gray-900" : "border-gray-700"}
        `}
        onClick={() => !disabled && setIsOpen(!isOpen)}
      >
        <span
          className={`block truncate text-sm font-medium ${!selectedOption && !selectedLabel ? "text-gray-500" : "text-white"}`}
        >
          {displayLabel}
        </span>

        <div className="flex items-center gap-1.5 ml-2">
          {value && !disabled && (
            <button
              onClick={handleClear}
              className="p-1 hover:bg-gray-700 rounded-full text-gray-400 hover:text-red-400 transition-all active:scale-90"
              title="Clear selection"
            >
              <X size={14} strokeWidth={2.5} />
            </button>
          )}
          <ChevronDown
            size={16}
            className={`text-gray-500 transition-transform duration-200 ${isOpen ? "rotate-180 text-blue-400" : ""}`}
          />
        </div>
      </div>

      {/* Dropdown Menu */}
      {isOpen && (
        <div className="absolute z-50 mt-2 w-full bg-gray-900/95 backdrop-blur-xl shadow-2xl max-h-72 rounded-2xl border border-white/10 overflow-hidden animate-in fade-in slide-in-from-top-1 duration-200">
          {/* Search Input Container */}
          <div className="p-3 border-b border-white/5 sticky top-0 bg-gray-900/40 backdrop-blur-sm z-10">
            <div className="relative group">
              <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                <Search
                  size={14}
                  className="text-gray-500 group-focus-within:text-blue-400 transition-colors"
                />
              </div>
              <input
                ref={inputRef}
                type="text"
                className="block w-full pl-10 pr-4 py-2 bg-gray-800/80 border border-gray-700 rounded-xl text-sm text-white placeholder-gray-500 focus:outline-none focus:border-blue-500/50 focus:ring-4 focus:ring-blue-500/10 transition-all"
                placeholder="Search items..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                onClick={(e) => e.stopPropagation()}
              />
            </div>
          </div>

          {/* Options List */}
          <div className="max-h-56 overflow-auto scrollbar-thin scrollbar-thumb-gray-700 scrollbar-track-transparent">
            {displayOptions.length === 0 ? (
              <div className="py-8 px-4 text-gray-500 text-center italic text-sm">
                No results for "{searchTerm}"
              </div>
            ) : (
              <div className="py-1">
                {displayOptions.map((option) => (
                  <div
                    key={option.id}
                    className={`cursor-pointer select-none relative py-2.5 pl-4 pr-10 transition-colors ${
                      value === option.id
                        ? "bg-blue-600/20 text-blue-400 font-bold"
                        : "text-gray-300 hover:bg-white/5 hover:text-white"
                    }`}
                    onClick={() => handleSelect(option)}
                  >
                    <span className="block truncate">{option.name}</span>
                    {value === option.id && (
                      <span className="absolute inset-y-0 right-0 flex items-center pr-4 text-blue-400">
                        <Check size={16} strokeWidth={3} />
                      </span>
                    )}
                  </div>
                ))}
                {onLoadMore && hasMore && (
                  <button
                    className="w-full py-3 px-4 text-center text-blue-400 hover:text-blue-300 hover:bg-white/5 transition-all text-sm font-bold border-t border-white/5 bg-gray-900/50"
                    onClick={(e) => {
                      e.stopPropagation();
                      if (!loadingMore) onLoadMore();
                    }}
                    disabled={loadingMore}
                  >
                    {loadingMore ? (
                      <span className="flex items-center justify-center gap-2">
                        <div className="w-3 h-3 border-2 border-blue-400 border-t-transparent rounded-full animate-spin"></div>
                        Loading...
                      </span>
                    ) : (
                      "View More items"
                    )}
                  </button>
                )}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default SearchableSelect;
