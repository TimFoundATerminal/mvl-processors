// Express server to handle file operations and process execution
const express = require('express');
const fs = require('fs');
const { exec } = require('child_process');
const path = require('path');
const cors = require('cors');
const csv = require('csv-parser');

const app = express();
const port = 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Endpoint the check if the server is running
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'Server is running' });
  });

// Endpoint to save assembly code to input.asm
app.post('/api/save-assembly', (req, res) => {
  const { code } = req.body;
  
  // Save to input.asm file
  fs.writeFile('input.asm', code, (err) => {
    if (err) {
      console.error('Error writing to input.asm:', err);
      return res.status(500).json({ error: 'Failed to write assembly code to file' });
    }
    
    res.json({ success: true, message: 'Assembly code saved to input.asm' });
  });
});

// Endpoint to execute run.bat
app.post('/api/execute', (req, res) => {
  // Execute run.bat
  exec('./run.bat', (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing run.bat: ${error}`);
      return res.status(500).json({ error: `Execution failed: ${error.message}` });
    }
    
    const output = stdout + stderr;
    
    // Read the gate count CSV files
    const binaryFile = path.join('Verilog', 'binary', 'programs', 'program_gate_counts.csv');
    const ternaryFile = path.join('Verilog', 'ternary', 'programs', 'program_gate_counts.csv');
    
    const binaryData = [];
    const ternaryData = [];
    
    // Read binary gate counts
    let binaryPromise = new Promise((resolve, reject) => {
      fs.createReadStream(binaryFile)
        .pipe(csv())
        .on('data', (row) => {
          // Assuming CSV has 'Gate' and 'Count' columns
          binaryData.push({
            Gate: row.Gate,
            Count: parseInt(row.Count, 10)
          });
        })
        .on('end', () => {
          resolve();
        })
        .on('error', (err) => {
          reject(err);
        });
    });
    
    // Read ternary gate counts
    let ternaryPromise = new Promise((resolve, reject) => {
      fs.createReadStream(ternaryFile)
        .pipe(csv())
        .on('data', (row) => {
          ternaryData.push({
            Gate: row.Gate,
            Count: parseInt(row.Count, 10)
          });
        })
        .on('end', () => {
          resolve();
        })
        .on('error', (err) => {
          reject(err);
        });
    });
    
    // Wait for both CSV files to be read
    Promise.all([binaryPromise, ternaryPromise])
      .then(() => {
        // Calculate totals
        const binaryTotal = binaryData.reduce((sum, item) => sum + item.Count, 0);
        const ternaryTotal = ternaryData.reduce((sum, item) => sum + item.Count, 0);
        
        // Add total row to each dataset
        binaryData.push({ Gate: 'TOTAL', Count: binaryTotal });
        ternaryData.push({ Gate: 'TOTAL', Count: ternaryTotal });
        
        // Send response with output and gate counts
        res.json({
          success: true,
          output,
          binaryData,
          ternaryData
        });
      })
      .catch((err) => {
        console.error('Error reading CSV files:', err);
        res.status(500).json({ error: 'Failed to read gate count data', output });
      });
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Assembly execution server listening at http://localhost:${port}`);
});