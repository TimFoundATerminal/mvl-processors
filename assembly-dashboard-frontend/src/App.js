import React, { useState, useEffect } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { ChevronDown, ChevronUp, PlayCircle, Code, Save, Info, AlertTriangle } from 'lucide-react';

// Default assembly code example
const DEFAULT_ASSEMBLY_CODE = `; Multiplication program for 6 × 7
LUI R0, 0    ; Initialize R0 to 0
LI R0, 6     ; Load 6 into R0
LUI R1, 0    ; Initialize R1 to 0
LI R1, 7     ; Load 7 into R1
LUI R2, 0    ; Initialize R2 (product) to 0
LUI R3, 0    ; Initialize R3 (counter) to 0

; Multiplication loop
ADD R2, R0    ; Add R0 to R2 (accumulate the product)
ADDI R3, 1    ; Increment counter
MV R4, R3     ; Copy into R4 to perform the compare
EQ R4, R1     ; Compare counter with multiplier
BNE R4, -4    ; If counter != multiplier, loop back 4 instructions

HALT          ;`;

// Instruction set information
const INSTRUCTION_SET = [
  { opcode: '0', type: 'R', mnemonic: 'MV a,b', description: 'RF[a] = RF[b]' },
  { opcode: '2', type: 'R', mnemonic: 'NOT a,b', description: 'RF[a] = NOT(RF[b])' },
  { opcode: '4', type: 'R', mnemonic: 'AND a,b', description: 'RF[a] = RF[a] ∧ RF[b]' },
  { opcode: '5', type: 'R', mnemonic: 'OR a,b', description: 'RF[a] = RF[a] ∨ RF[b]' },
  { opcode: '6', type: 'R', mnemonic: 'XOR a,b', description: 'RF[a] = RF[a] ⊕ RF[b]' },
  { opcode: '7', type: 'R', mnemonic: 'ADD a,b', description: 'RF[a] = RF[a] + RF[b]' },
  { opcode: '8', type: 'R', mnemonic: 'SUB a,b', description: 'RF[a] = RF[a] - RF[b]' },
  { opcode: '11', type: 'R', mnemonic: 'COMP a,b', description: 'RF[a] = compare(RF[a],RF[b])' },
  { opcode: '12', type: 'I', mnemonic: 'ANDI a,imm', description: 'RF[a] = RF[a] ∧ imm[7:0]' },
  { opcode: '13', type: 'I', mnemonic: 'ADDI a,imm', description: 'RF[a] = RF[a] + imm[7:0]' },
  { opcode: '14', type: 'R', mnemonic: 'LT a,b', description: 'RF[a] = RF[a] < RF[b]' },
  { opcode: '15', type: 'R', mnemonic: 'EQ a,b', description: 'RF[a] = RF[a] == RF[b]' },
  { opcode: '16', type: 'I', mnemonic: 'LUI a,imm', description: 'RF[a] = {imm[7:0],00000000}' },
  { opcode: '17', type: 'I', mnemonic: 'LI a,imm', description: 'RF[a] = {RF[a][15:8],imm[7:0]}' },
  { opcode: '18', type: 'B', mnemonic: 'BEQ a,imm', description: 'Branch if RF[a] == 0' },
  { opcode: '19', type: 'B', mnemonic: 'BNE a,imm', description: 'Branch if RF[a] != 0' },
  { opcode: '22', type: 'M', mnemonic: 'LOAD a,b,imm', description: 'RF[a] = TDM[RF[b]+imm[4:0]]' },
  { opcode: '23', type: 'M', mnemonic: 'STORE a,b,imm', description: 'TDM[RF[b]+imm[4:0]] = RF[a]' },
  { opcode: '31', type: '', mnemonic: 'HALT', description: 'Stop execution' }
];

// Initial data for charts (will be replaced with actual data)
const initialGateData = [
  { Gate: 'AND', Count: 0 },
  { Gate: 'OR', Count: 0 },
  { Gate: 'NOT', Count: 0 },
  { Gate: 'XOR', Count: 0 },
  { Gate: 'TOTAL', Count: 0 }
];

// API service functions
const API_BASE_URL = 'http://localhost:3001/api';

async function saveAssemblyCode(code) {
  try {
    const response = await fetch(`${API_BASE_URL}/save-assembly`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ code }),
    });
    
    return await response.json();
  } catch (error) {
    console.error('Error saving assembly code:', error);
    throw error;
  }
}

async function executeAssembly() {
  try {
    const response = await fetch(`${API_BASE_URL}/execute`, {
      method: 'POST',
    });
    
    return await response.json();
  } catch (error) {
    console.error('Error executing assembly:', error);
    throw error;
  }
}

// Main Application Component
const AssemblyEditor = () => {
  const [code, setCode] = useState(DEFAULT_ASSEMBLY_CODE);
  const [isExecuting, setIsExecuting] = useState(false);
  const [showInstructionSet, setShowInstructionSet] = useState(false);
  const [binaryGateData, setBinaryGateData] = useState(initialGateData);
  const [ternaryGateData, setTernaryGateData] = useState(initialGateData);
  const [consoleOutput, setConsoleOutput] = useState([]);
  const [error, setError] = useState(null);
  const [isDemoMode, setIsDemoMode] = useState(false);
  
  // Determine if we're running in demo mode or can connect to the backend
  useEffect(() => {
    // Try to connect to the backend, if it fails, enter demo mode
    fetch(`${API_BASE_URL}/health`)
      .then(response => {
        if (!response.ok) {
          setIsDemoMode(true);
        }
      })
      .catch(err => {
        console.log('Backend not available, entering demo mode');
        setIsDemoMode(true);
      });
  }, []);
  
  // Function to save and execute the assembly code
  const handleExecute = async () => {
    setIsExecuting(true);
    setError(null);
    clearConsole();
    setConsoleOutput(prev => [...prev, '> Executing assembly code...']);
    
    if (isDemoMode) {
      // Demo mode simulation
      executeDemoMode();
    } else {
      try {
        // Real execution flow
        setConsoleOutput(prev => [...prev, '> Saving assembly code to input.asm']);
        await saveAssemblyCode(code);
        
        setConsoleOutput(prev => [...prev, '> Executing run.bat']);
        const result = await executeAssembly();
        
        if (result.success) {
          // Parse output
          const outputLines = result.output.split('\n').filter(line => line.trim());
          setConsoleOutput(prev => [...prev, ...outputLines.map(line => `> ${line}`)]);
          
          // Update gate count data
          setBinaryGateData(result.binaryData);
          setTernaryGateData(result.ternaryData);
          
          setConsoleOutput(prev => [...prev, '> Execution completed successfully']);
        } else {
          setError(result.error || 'Unknown error occurred');
          setConsoleOutput(prev => [...prev, `> Error: ${result.error}`]);
        }
      } catch (error) {
        setError(`Failed to execute: ${error.message}`);
        setConsoleOutput(prev => [...prev, `> Error: ${error.message}`]);
      }
    }
    
    setIsExecuting(false);
  };
  
  // Demo mode execution (for when backend is not available)
  const executeDemoMode = () => {
    setConsoleOutput(prev => [...prev, '> Running in demo mode (no backend connection)']);
    setConsoleOutput(prev => [...prev, '> Writing code to input.asm (simulated)']);
    
    setTimeout(() => {
      setConsoleOutput(prev => [...prev, '> Executing run.bat (simulated)']);
      
      setTimeout(() => {
        // Simulated compiler output
        setConsoleOutput(prev => [
          ...prev, 
          '> Binary compiler: Successfully assembled binary instructions',
          '> Ternary compiler: Successfully assembled ternary instructions',
          '> Program Execution Started',
          '> PC=0',
          '> R0=0 R1=0 R2=0 R3=0 R4=0 R5=0',
          '> PC=2',
          '> R0=6 R1=0 R2=0 R3=0 R4=0 R5=0',
          '> PC=4',
          '> R0=6 R1=7 R2=0 R3=0 R4=0 R5=0',
          '> PC=6',
          '> R0=6 R1=7 R2=6 R3=1 R4=1 R5=0',
          '> PC=8',
          '> R0=6 R1=7 R2=12 R3=2 R4=2 R5=0',
          '> PC=10',
          '> R0=6 R1=7 R2=18 R3=3 R4=3 R5=0',
          '> PC=12',
          '> R0=6 R1=7 R2=24 R3=4 R4=4 R5=0',
          '> PC=14',
          '> R0=6 R1=7 R2=30 R3=5 R4=5 R5=0',
          '> PC=16',
          '> R0=6 R1=7 R2=36 R3=6 R4=6 R5=0',
          '> PC=18',
          '> R0=6 R1=7 R2=42 R3=7 R4=7 R5=0',
          '> Final Register Values:',
          '> R0=6',
          '> R1=7',
          '> R2=42',
          '> R3=7',
          '> R4=1',
          '> R5=0',
          '> R6=0',
          '> R7=0'
        ]);
        
        // Generate random gate count data for the demo
        const generateRandomGateData = () => {
          const randomizeCount = () => Math.floor(Math.random() * 2000) + 100;
          
          const gates = ['AND', 'OR', 'NOT', 'XOR'];
          const data = gates.map(gate => ({ 
            Gate: gate, 
            Count: randomizeCount() 
          }));
          
          // Calculate and add the total
          const total = data.reduce((sum, item) => sum + item.Count, 0);
          data.push({ Gate: 'TOTAL', Count: total });
          
          return data;
        };
        
        setBinaryGateData(generateRandomGateData());
        setTernaryGateData(generateRandomGateData().map(item => ({
          ...item,
          Gate: item.Gate === 'TOTAL' ? 'TOTAL' : `Ternary ${item.Gate}`
        })));
        
        setConsoleOutput(prev => [...prev, '> Execution completed (demo mode)']);
      }, 1000);
    }, 500);
  };
  
  // Reset console output
  const clearConsole = () => {
    setConsoleOutput([]);
  };
  
  // Handle "Save" button click
  const handleSaveClick = async () => {
    if (isDemoMode) {
      alert('Save functionality is disabled in demo mode');
      return;
    }
    
    try {
      await saveAssemblyCode(code);
      setConsoleOutput(prev => [...prev, '> Assembly code saved to input.asm']);
    } catch (error) {
      setError(`Failed to save: ${error.message}`);
      setConsoleOutput(prev => [...prev, `> Error saving code: ${error.message}`]);
    }
  };

  return (
    <div className="flex flex-col h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-indigo-700 text-white p-4 shadow-md">
        <div className="container mx-auto flex justify-between items-center">
          <h1 className="text-2xl font-bold">Assembly Execution Dashboard</h1>
          <div className="flex items-center space-x-2">
            {isDemoMode && (
              <span className="bg-yellow-600 text-xs px-2 py-1 rounded flex items-center">
                <AlertTriangle size={12} className="mr-1" />
                Demo Mode
              </span>
            )}
            <button 
              className="flex items-center px-3 py-2 bg-indigo-600 rounded-md hover:bg-indigo-800 transition-colors"
              onClick={() => setShowInstructionSet(!showInstructionSet)}
            >
              <Info size={16} className="mr-1" />
              Instruction Set
              {showInstructionSet ? <ChevronUp size={16} className="ml-1" /> : <ChevronDown size={16} className="ml-1" />}
            </button>
          </div>
        </div>
      </header>
      
      {/* Instruction Set Reference */}
      {showInstructionSet && (
        <div className="bg-white border-b border-gray-200 shadow-sm">
          <div className="container mx-auto py-3 px-4">
            <h2 className="text-lg font-semibold mb-2">Instruction Set Reference</h2>
            <div className="overflow-x-auto">
              <table className="min-w-full bg-white text-sm">
                <thead className="bg-gray-100">
                  <tr>
                    <th className="py-2 px-3 text-left">Opcode</th>
                    <th className="py-2 px-3 text-left">Type</th>
                    <th className="py-2 px-3 text-left">Mnemonic</th>
                    <th className="py-2 px-3 text-left">Description</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {INSTRUCTION_SET.map((instruction, idx) => (
                    <tr key={idx} className="hover:bg-gray-50">
                      <td className="py-2 px-3">{instruction.opcode}</td>
                      <td className="py-2 px-3">{instruction.type}</td>
                      <td className="py-2 px-3 font-mono">{instruction.mnemonic}</td>
                      <td className="py-2 px-3">{instruction.description}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}
      
      {/* Main Content */}
      <div className="flex-grow flex flex-col lg:flex-row p-4 gap-4 overflow-hidden">
        {/* Editor Panel */}
        <div className="lg:w-1/2 flex flex-col rounded-lg shadow-md bg-white overflow-hidden">
          <div className="flex items-center justify-between p-3 bg-gray-100 border-b">
            <div className="flex items-center">
              <Code size={18} className="text-gray-600 mr-2" />
              <h2 className="font-medium">Assembly Code Editor</h2>
            </div>
            <div className="flex space-x-2">
              <button 
                className="text-xs px-2 py-1 bg-gray-200 hover:bg-gray-300 rounded"
                onClick={() => setCode(DEFAULT_ASSEMBLY_CODE)}
              >
                Reset
              </button>
              <button 
                className="text-xs px-2 py-1 bg-green-100 text-green-800 hover:bg-green-200 rounded flex items-center"
                onClick={handleSaveClick}
              >
                <Save size={12} className="mr-1" />
                Save
              </button>
            </div>
          </div>
          <div className="flex-grow relative">
            <textarea
              className="w-full h-full p-4 font-mono text-sm focus:outline-none resize-none"
              value={code}
              onChange={(e) => setCode(e.target.value)}
              spellCheck="false"
            />
          </div>
          <div className="p-3 bg-gray-100 border-t">
            <button
              className={`w-full py-2 ${
                isExecuting 
                  ? 'bg-gray-500 cursor-not-allowed' 
                  : 'bg-indigo-600 hover:bg-indigo-700'
              } text-white rounded-md flex items-center justify-center transition-colors`}
              onClick={handleExecute}
              disabled={isExecuting}
            >
              <PlayCircle size={18} className="mr-2" />
              {isExecuting ? 'Executing...' : 'Execute Assembly Code'}
            </button>
          </div>
        </div>
        
        {/* Results Panel */}
        <div className="lg:w-1/2 flex flex-col gap-4">
          {/* Console Output */}
          <div className="bg-gray-900 text-gray-100 rounded-lg shadow-md p-4 h-48 overflow-y-auto font-mono text-sm">
            <div className="flex justify-between items-center mb-2">
              <h3 className="text-xs uppercase tracking-wide text-gray-400">Console Output</h3>
              <button 
                onClick={clearConsole}
                className="text-xs text-gray-400 hover:text-white"
              >
                Clear
              </button>
            </div>
            {consoleOutput.length > 0 ? (
              consoleOutput.map((line, idx) => (
                <div key={idx} className="py-1">
                  {line}
                </div>
              ))
            ) : (
              <div className="text-gray-500 italic">Execute code to see output here...</div>
            )}
          </div>
          
          {/* Error display */}
          {error && (
            <div className="bg-red-100 border border-red-300 text-red-800 px-4 py-3 rounded-md flex items-start">
              <AlertTriangle size={18} className="text-red-600 mr-2 mt-1 flex-shrink-0" />
              <div>
                <div className="font-medium">Error occurred</div>
                <div className="text-sm">{error}</div>
              </div>
            </div>
          )}
          
          {/* Visualizations */}
          <div className="flex-grow grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Binary Gate Count */}
            <div className="bg-white rounded-lg shadow-md p-4 flex flex-col">
              <h3 className="text-lg font-medium text-gray-800 mb-2">Binary Gate Count</h3>
              <div className="flex-grow">
                <ResponsiveContainer width="100%" height={200}>
                  <BarChart data={binaryGateData.filter(item => item.Gate !== 'TOTAL')}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="Gate" />
                    <YAxis />
                    <Tooltip />
                    <Bar dataKey="Count" fill="#6366f1" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
              <div className="mt-2 text-right text-sm font-semibold">
                Total Gates: {binaryGateData.find(item => item.Gate === 'TOTAL')?.Count || 0}
              </div>
            </div>
            
            {/* Ternary Gate Count */}
            <div className="bg-white rounded-lg shadow-md p-4 flex flex-col">
              <h3 className="text-lg font-medium text-gray-800 mb-2">Ternary Gate Count</h3>
              <div className="flex-grow">
                <ResponsiveContainer width="100%" height={200}>
                  <BarChart data={ternaryGateData.filter(item => item.Gate !== 'TOTAL')}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="Gate" />
                    <YAxis />
                    <Tooltip />
                    <Bar dataKey="Count" fill="#8b5cf6" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
              <div className="mt-2 text-right text-sm font-semibold">
                Total Gates: {ternaryGateData.find(item => item.Gate === 'TOTAL')?.Count || 0}
              </div>
            </div>
          </div>
        </div>
      </div>
      
      {/* Footer */}
      <footer className="bg-gray-100 text-gray-600 text-center py-3 text-sm border-t">
        Assembly Execution Dashboard | Created 2025
      </footer>
    </div>
  );
};

export default AssemblyEditor;