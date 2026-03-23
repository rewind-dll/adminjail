import React from 'react';

interface TabletFrameProps {
  children: React.ReactNode;
  onClose: () => void;
}

export const TabletFrame: React.FC<TabletFrameProps> = ({ children, onClose }) => {
  return (
    <div className="relative w-[1000px] h-[680px] bg-[#1a1a1e] rounded-[3rem] p-4 shadow-[0_50px_100px_-20px_rgba(0,0,0,1)] border-[8px] border-[#2a2a2e]">
      {/* Front Camera & Sensors */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-32 h-6 bg-[#2a2a2e] rounded-b-2xl flex items-center justify-center gap-3 px-4 z-50">
        <div className="size-2 rounded-full bg-[#1a1a1e] border border-white/5" />
        <div className="w-8 h-1 bg-[#1a1a1e] rounded-full" />
      </div>

      {/* Screen Content Container */}
      <div className="relative w-full h-full bg-[#0c0c0e] rounded-[2rem] overflow-hidden flex flex-col border border-black shadow-inner">
        {/* Tablet Status Bar */}
        <div className="h-8 px-8 flex items-center justify-between text-[10px] text-zinc-500 font-bold uppercase tracking-widest bg-black/20">
          <div className="flex items-center gap-4">
            <span>9:41 AM</span>
            <span className="text-blue-500/50">ADMIN SECURE NET</span>
          </div>
          <div className="flex items-center gap-3">
            <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 21l-12-18h24z" />
            </svg>
            <div className="w-5 h-2.5 border border-current rounded-sm relative">
              <div className="absolute inset-0.5 bg-zinc-500 rounded-sm w-[80%]" />
              <div className="absolute -right-1 top-0.5 w-0.5 h-1 bg-current rounded-r-sm" />
            </div>
          </div>
        </div>

        {/* The actual App content */}
        <div className="flex-1 min-h-0 relative">
          {children}
        </div>

        {/* Tablet Home Indicator */}
        <div className="h-6 flex items-center justify-center">
          <div className="w-32 h-1 bg-white/10 rounded-full" />
        </div>
      </div>

      {/* Hardware Buttons */}
      <div className="absolute -right-[10px] top-24 w-[2px] h-16 bg-[#3a3a3e] rounded-r-lg" />
      <div className="absolute -right-[10px] top-44 w-[2px] h-12 bg-[#3a3a3e] rounded-r-lg" />
      <div className="absolute -right-[10px] top-60 w-[2px] h-12 bg-[#3a3a3e] rounded-r-lg" />
    </div>
  );
};
