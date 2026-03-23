import React, { useState, useEffect } from 'react';

interface JailTimerHUDProps {
  remaining: number;
  reason: string;
}

export const JailTimerHUD: React.FC<JailTimerHUDProps> = ({ remaining: initialRemaining, reason }) => {
  const [remaining, setRemaining] = useState(initialRemaining);

  // Sync with prop updates from server
  useEffect(() => {
    setRemaining(initialRemaining);
  }, [initialRemaining]);

  // Local countdown every minute
  useEffect(() => {
    if (remaining <= 0) return;

    const timer = setInterval(() => {
      setRemaining((prev) => Math.max(0, prev - 1));
    }, 60000); // 1 minute

    return () => clearInterval(timer);
  }, [remaining]);

  return (
    <div className="fixed top-8 left-1/2 -translate-x-1/2 z-50 pointer-events-none font-sans isolate">
      <div className="bg-[#0c0c0e]/90 border border-blue-500/20 rounded-full pl-2 pr-6 py-2 flex items-center gap-4 overflow-hidden isolate">
        {/* Compact Icon - Centered and refined */}
        <div className="size-8 bg-gradient-to-br from-blue-600 to-blue-700 rounded-full flex items-center justify-center shadow-lg border border-white/10 shrink-0">
          <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2z" />
          </svg>
        </div>

        {/* Content Group */}
        <div className="flex items-center gap-4 min-w-0">
          {/* Timer Section */}
          <div className="flex items-center gap-2 shrink-0">
            <span className="text-blue-500 text-[10px] font-black uppercase tracking-[0.2em]">
              Jailed
            </span>
            <span className="text-white text-base font-black tabular-nums tracking-tight leading-none">
              {remaining}
              <span className="text-zinc-500 text-[10px] ml-0.5 font-bold uppercase">m</span>
            </span>
          </div>

          {/* Divider */}
          <div className="h-4 w-px bg-white/10" />

          {/* Reason Section */}
          <div className="flex items-center gap-2 min-w-0">
            <span className="text-zinc-600 text-[9px] font-bold uppercase tracking-widest shrink-0">Reason:</span>
            <span className="text-zinc-400 text-[10px] font-bold uppercase tracking-wider truncate max-w-[150px]">
              {reason || 'None Specified'}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};
