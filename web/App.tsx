import { useState, useCallback, useEffect } from 'react';
import { isDebug, useNuiEvent, fetchNui } from './hooks/useNui';
import { JailForm } from './components/JailForm';
import { JailedList, JailedPlayer } from './components/JailedList';
import { TabletFrame } from './components/TabletFrame';
import { JailTimerHUD } from './components/JailTimerHUD';

export default function App() {
  const [visible, setVisible] = useState(isDebug);
  const [isJailed, setIsJailed] = useState(isDebug);
  const [jailData, setJailData] = useState({ remaining: 8, reason: 'test' });
  const [players, setPlayers] = useState<JailedPlayer[]>([]);

  const refreshPlayers = useCallback((): any => {
    return fetchNui<JailedPlayer[]>('getJailedPlayers', {}, [
      { id: 1, name: 'John Doe', remaining: 15, reason: 'RDM' },
      { id: 24, name: 'Jane Smith', remaining: 42, reason: 'FailRP' },
      { id: 102, name: 'Mike Ross', remaining: 120, reason: 'VDM & FearRP' },
    ]).then((data: any) => setPlayers(data));
  }, []);

  useNuiEvent('open', (data: any) => {
    setVisible(true);
    if (data?.players) setPlayers(data.players);
    else refreshPlayers();
  });

  useNuiEvent('setJailStatus', (data: { jailed: boolean; remaining: number; reason: string }) => {
    setIsJailed(data.jailed);
    setJailData({ remaining: data.remaining, reason: data.reason });
  });
  
  useNuiEvent('close', () => setVisible(false));
  
  useNuiEvent('refresh', (data: JailedPlayer[]) => {
    if (data && data.length !== undefined) {
      setPlayers(data);
    } else {
      refreshPlayers();
    }
  });

  const handleClose = useCallback(() => {
    setVisible(false);
    fetchNui('close', {}, { success: true });
  }, []);

  useEffect(() => {
    const onKeyDown = (e: any) => {
      if (e.key === 'Escape') handleClose();
    };
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [handleClose]);

  return (
    <>
      {/* HUD - Shown independently of tablet visibility */}
      {isJailed && <JailTimerHUD remaining={jailData.remaining} reason={jailData.reason} />}
      
      {/* Tablet UI */}
      {visible && (
        <div className="w-screen h-screen flex items-center justify-center font-sans text-zinc-200 selection:bg-blue-500/30 pointer-events-none">
          <div className="pointer-events-auto">
            <TabletFrame onClose={handleClose}>
              <div className="h-full flex flex-col bg-[#0c0c0e]">
                {/* App Header */}
                <header className="px-10 py-8 flex items-center justify-between">
                  <div className="flex items-center gap-5">
                    <div className="size-14 bg-gradient-to-br from-blue-600 to-blue-700 rounded-2xl flex items-center justify-center shadow-[0_8px_20px_-6px_rgba(37,99,235,0.5)] border border-white/10">
                      <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2z" />
                      </svg>
                    </div>
                    <div>
                      <h1 className="text-white text-2xl font-black uppercase tracking-tight leading-none">Admin Jail MANAGEMENT</h1>
                      <p className="text-zinc-500 text-xs font-bold uppercase tracking-[0.2em] mt-2 flex items-center gap-2">
                        Secure Administrative Access
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-3">
                    <button
                      onClick={refreshPlayers}
                      className="p-3 hover:bg-white/5 rounded-xl transition-all border border-transparent hover:border-white/5 group"
                      title="Sync Database"
                    >
                      <svg className="w-6 h-6 text-zinc-500 group-hover:text-blue-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                      </svg>
                    </button>
                    <div className="h-8 w-px bg-white/5 mx-2" />
                    <button
                      onClick={handleClose}
                      className="bg-red-500/10 hover:bg-red-500 text-red-500 hover:text-white px-5 py-2.5 rounded-xl font-bold text-xs uppercase tracking-widest transition-all border border-red-500/20"
                    >
                      Exit App
                    </button>
                  </div>
                </header>

                {/* App Body */}
                <div className="flex-1 flex gap-10 px-10 pb-8 min-h-0">
                  <aside className="w-[340px] flex flex-col gap-6">
                    <JailForm onSuccess={refreshPlayers} />
                  </aside>
                  
                  <main className="flex-1 min-h-0 bg-zinc-900/20 rounded-2xl border border-white/[0.02]">
                    <JailedList players={players} onAction={refreshPlayers} />
                  </main>
                </div>
              </div>
            </TabletFrame>
          </div>

          {/* Background decoration - only for tablet */}
          <div className="fixed inset-0 pointer-events-none opacity-40 bg-[radial-gradient(circle_at_50%_50%,rgba(37,99,235,0.05),transparent)] -z-10" />
        </div>
      )}
    </>
  );
}
