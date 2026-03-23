import React from 'react';
import { fetchNui } from '../hooks/useNui';

export interface JailedPlayer {
  id: number;
  name: string;
  remaining: number;
  reason: string;
}

interface JailedListProps {
  players: JailedPlayer[];
  onAction: () => void;
}

export const JailedList: React.FC<JailedListProps> = ({ players, onAction }) => {
  const handleUnjail = (id: number): any => {
    return fetchNui<boolean>('unjailPlayer', { targetId: id }, true).then((success: any) => {
      if (success) onAction();
    });
  };

  return (
    <div className="bg-zinc-900/40 backdrop-blur-sm p-5 rounded-xl border border-white/[0.03] shadow-inner flex flex-col h-full">
      <div className="flex items-center justify-between mb-5">
        <div className="flex items-center gap-2">
          <div className="size-1.5 rounded-full bg-blue-500 shadow-[0_0_8px_rgba(59,130,246,0.5)]" />
          <h2 className="text-zinc-100 text-sm font-bold uppercase tracking-wider">
            Active Records
          </h2>
        </div>
        <div className="px-2.5 py-1 bg-white/5 rounded-md border border-white/5 flex items-center gap-2">
          <span className="text-[10px] text-zinc-500 uppercase font-bold tracking-widest">Total</span>
          <span className="text-zinc-100 text-xs font-mono font-bold leading-none">{players.length}</span>
        </div>
      </div>
      
      <div className="flex-1 overflow-y-auto space-y-3 pr-2 custom-scrollbar">
        {players.length === 0 ? (
          <div className="h-full flex flex-col items-center justify-center text-zinc-600 gap-3 grayscale opacity-40">
            <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span className="text-xs font-bold uppercase tracking-widest">Zero Active Sentences</span>
          </div>
        ) : (
          players.map((player) => (
            <div 
              key={player.id}
              className="group relative bg-black/40 border border-white/[0.05] rounded-xl p-4 flex items-center justify-between hover:border-blue-500/30 hover:bg-black/60 transition-all duration-300"
            >
              <div className="absolute left-0 top-1/2 -translate-y-1/2 w-[2px] h-1/2 bg-blue-500 opacity-0 group-hover:opacity-100 transition-opacity rounded-r-full" />
              
              <div className="min-w-0 flex items-center gap-4">
                <div className="size-10 bg-zinc-800/50 rounded-lg flex items-center justify-center border border-white/5 text-zinc-400 font-mono text-xs group-hover:text-blue-400 transition-colors">
                  {player.id}
                </div>
                <div className="min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-zinc-100 font-bold tracking-tight truncate">{player.name}</span>
                    <span className="text-[9px] px-1.5 py-0.5 bg-zinc-800 text-zinc-500 rounded uppercase font-black tracking-tighter">Inmate</span>
                  </div>
                  <div className="text-xs text-zinc-500 truncate leading-relaxed max-w-[200px]">
                    {player.reason}
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-5 ml-4">
                <div className="text-right">
                  <div className="text-blue-400 font-mono text-lg font-bold leading-none tabular-nums">
                    {player.remaining}
                    <span className="text-[10px] ml-0.5 opacity-50 font-sans">M</span>
                  </div>
                  <div className="text-[9px] uppercase tracking-widest text-zinc-600 font-black mt-1">Remaining</div>
                </div>
                <button
                  onClick={() => handleUnjail(player.id)}
                  className="size-9 flex items-center justify-center bg-zinc-800/50 hover:bg-blue-600 hover:text-white text-zinc-500 rounded-lg transition-all border border-white/5 hover:border-blue-500 hover:shadow-[0_0_15px_rgba(37,99,235,0.3)]"
                  title="Grant Parole"
                >
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 11V7a4 4 0 118 0m-4 8v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2z" />
                  </svg>
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};
