import React, { useState } from 'react';
import { fetchNui } from '../hooks/useNui';

interface JailFormProps {
  onSuccess: () => void;
}

export const JailForm: React.FC<JailFormProps> = ({ onSuccess }) => {
  const [targetId, setTargetId] = useState('');
  const [duration, setDuration] = useState('');
  const [reason, setReason] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent): any => {
    e.preventDefault();
    if (!targetId || !duration || !reason) return;

    setLoading(true);
    return fetchNui<boolean>('jailPlayer', {
      targetId: parseInt(targetId),
      duration: parseInt(duration),
      reason,
    }, true).then((success: any) => {
      if (success) {
        setTargetId('');
        setDuration('');
        setReason('');
        onSuccess();
      }
      setLoading(false);
    });
  };

  return (
    <div className="bg-zinc-900/40 backdrop-blur-sm p-5 rounded-xl border border-white/[0.03] shadow-inner flex flex-col gap-5">
      <div className="flex items-center gap-2">
        <div className="size-1.5 rounded-full bg-red-500 shadow-[0_0_8px_rgba(239,68,68,0.5)] animate-pulse" />
        <h2 className="text-zinc-100 text-sm font-bold uppercase tracking-wider">
          New Sentence
        </h2>
      </div>

      <form onSubmit={handleSubmit} className="space-y-5">
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-1.5">
            <label className="text-[10px] uppercase tracking-[0.1em] text-zinc-500 font-bold ml-1">
              Player ID
            </label>
            <input
              type="number"
              value={targetId}
              onChange={(e) => setTargetId(e.target.value)}
              placeholder="0"
              className="w-full bg-black/40 border border-white/[0.05] rounded-lg p-2.5 text-zinc-200 focus:outline-none focus:border-blue-500/50 focus:bg-black/60 transition-all placeholder:text-zinc-700"
            />
          </div>
          <div className="space-y-1.5">
            <label className="text-[10px] uppercase tracking-[0.1em] text-zinc-500 font-bold ml-1">
              Time <span className="text-zinc-600">(Min)</span>
            </label>
            <input
              type="number"
              value={duration}
              onChange={(e) => setDuration(e.target.value)}
              placeholder="30"
              className="w-full bg-black/40 border border-white/[0.05] rounded-lg p-2.5 text-zinc-200 focus:outline-none focus:border-blue-500/50 focus:bg-black/60 transition-all placeholder:text-zinc-700"
            />
          </div>
        </div>
        <div className="space-y-1.5">
          <label className="text-[10px] uppercase tracking-[0.1em] text-zinc-500 font-bold ml-1">
            Reason for Enforcement
          </label>
          <textarea
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="Describe the violation..."
            rows={4}
            className="w-full bg-black/40 border border-white/[0.05] rounded-lg p-2.5 text-zinc-200 focus:outline-none focus:border-blue-500/50 focus:bg-black/60 transition-all resize-none placeholder:text-zinc-700 text-sm leading-relaxed"
          />
        </div>
        <button
          type="submit"
          disabled={loading}
          className="group relative w-full bg-blue-600 hover:bg-blue-500 disabled:bg-zinc-800 disabled:text-zinc-600 text-white font-bold py-3 rounded-lg transition-all shadow-lg overflow-hidden"
        >
          <div className="absolute inset-0 bg-gradient-to-tr from-white/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
          <span className="relative flex items-center justify-center gap-2">
            {loading ? 'Processing...' : (
              <>
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2z" />
                </svg>
                Issue Sentence
              </>
            )}
          </span>
        </button>
      </form>
    </div>
  );
};
