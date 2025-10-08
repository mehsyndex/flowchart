<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Interactive Flowchart Builder</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: #f5f7fa;
            height: 100vh;
            overflow: hidden;
        }

        .container {
            display: flex;
            height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            width: 400px;
            background: white;
            border-right: 1px solid #e1e4e8;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .sidebar-header {
            padding: 20px;
            border-bottom: 1px solid #e1e4e8;
            background: #2d5f8d;
            color: white;
        }

        .sidebar-header h1 {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .sidebar-header p {
            font-size: 13px;
            opacity: 0.9;
        }

        .banner-upload {
            padding: 20px;
            border-bottom: 1px solid #e1e4e8;
            background: #f8f9fa;
        }

        .banner-upload h3 {
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 10px;
            color: #333;
        }

        .upload-area {
            border: 2px dashed #cbd5e0;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s;
        }

        .upload-area:hover {
            border-color: #2d5f8d;
            background: #f0f4f8;
        }

        .upload-area.has-file {
            border-color: #2d5f8d;
            background: #e6f0f8;
        }

        .upload-icon {
            font-size: 32px;
            margin-bottom: 8px;
        }

        .upload-text {
            font-size: 13px;
            color: #666;
        }

        .banner-preview {
            margin-top: 10px;
            max-height: 80px;
            display: none;
        }

        .banner-preview img {
            max-width: 100%;
            max-height: 80px;
            border-radius: 4px;
        }

        .nodes-section {
            flex: 1;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }

        .nodes-header {
            padding: 20px 20px 0 20px;
            background: white;
            position: sticky;
            top: 0;
            z-index: 10;
        }

        .nodes-list-container {
            flex: 1;
            overflow-y: auto;
            padding: 0 20px 20px 20px;
        }

        .add-node-btn {
            width: 100%;
            padding: 12px;
            background: #2d5f8d;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            margin-bottom: 20px;
            transition: background 0.2s;
        }

        .add-node-btn:hover {
            background: #1e4466;
        }

        .node-item {
            background: white;
            border: 1px solid #e1e4e8;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 12px;
            transition: all 0.2s;
            cursor: pointer;
            position: relative;
        }

        .node-item.start-node {
            border-left: 4px solid #059669;
            background: linear-gradient(to right, #f0fdf4 0%, white 20%);
        }

        .node-item.start-node::before {
            content: '▶ START';
            position: absolute;
            top: -10px;
            left: 10px;
            background: #059669;
            color: white;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: 600;
        }

        .node-item:hover {
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .node-item.active {
            border-color: #2d5f8d;
            box-shadow: 0 0 0 3px rgba(45,95,141,0.1);
        }

        .node-item.dragging {
            opacity: 0.5;
            cursor: grabbing;
        }

        .node-item.drag-over {
            border-top: 3px solid #2d5f8d;
        }

        .node-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        .node-type-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .drag-handle {
            cursor: grab;
            font-size: 14px;
            opacity: 0.5;
            user-select: none;
        }

        .drag-handle:active {
            cursor: grabbing;
        }

        .node-type-badge.info {
            background: #e6f0f8;
            color: #2d5f8d;
        }

        .node-type-badge.decision {
            background: #fef3e6;
            color: #d97706;
        }

        .node-actions {
            display: flex;
            gap: 5px;
        }

        .node-actions button {
            padding: 4px 8px;
            border: none;
            background: #f1f3f5;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            transition: background 0.2s;
        }

        .node-actions button:hover {
            background: #e1e4e8;
        }

        .node-actions .delete {
            color: #dc2626;
        }

        .node-title {
            font-weight: 600;
            font-size: 14px;
            color: #333;
            margin-bottom: 5px;
        }

        .node-description {
            font-size: 13px;
            color: #666;
            margin-bottom: 10px;
        }

        .node-connections {
            font-size: 12px;
            color: #888;
            padding-top: 10px;
            border-top: 1px solid #f1f3f5;
        }

        .node-incoming {
            font-size: 11px;
            color: #6366f1;
            background: #eef2ff;
            padding: 4px 8px;
            border-radius: 4px;
            margin-top: 8px;
            display: inline-block;
        }

        .node-number-badge {
            background: #333;
            color: white;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            font-family: monospace;
        }

        .role-badge {
            color: white;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
        }

        .stage-badge {
            background: #f1f3f5;
            color: #495057;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
        }

        /* Preview Panel */
        .preview-panel {
            flex: 1;
            background: #f8f9fa;
            display: flex;
            flex-direction: column;
        }

        .preview-header {
            padding: 20px;
            background: white;
            border-bottom: 1px solid #e1e4e8;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
        }

        .preview-header h2 {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .preview-mode-toggle {
            display: flex;
            gap: 5px;
            background: #f1f3f5;
            padding: 4px;
            border-radius: 6px;
        }

        .preview-mode-toggle button {
            padding: 6px 12px;
            background: transparent;
            border: none;
            border-radius: 4px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            color: #666;
        }

        .preview-mode-toggle button.active {
            background: white;
            color: #2d5f8d;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        /* Flow Diagram Styles */
        .flow-diagram {
            padding: 40px;
            overflow: auto;
            min-height: 400px;
            background: #fafbfc;
        }

        .flow-diagram-container {
            display: inline-block;
            min-width: 100%;
        }

        .flow-node {
            background: white;
            border: 2px solid #e1e4e8;
            border-radius: 8px;
            padding: 15px 20px;
            margin: 20px auto;
            max-width: 400px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            position: relative;
        }

        .flow-node.start {
            border-color: #059669;
            background: linear-gradient(to right, #f0fdf4 0%, white 20%);
        }

        .flow-node.start::before {
            content: '▶ START';
            position: absolute;
            top: -12px;
            left: 15px;
            background: #059669;
            color: white;
            padding: 3px 10px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
        }

        .flow-node.selected {
            border-color: #2d5f8d;
            box-shadow: 0 0 0 3px rgba(45,95,141,0.1);
        }

        .flow-node-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        }

        .flow-node-type {
            background: #e6f0f8;
            color: #2d5f8d;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
        }

        .flow-node-type.decision {
            background: #fef3e6;
            color: #d97706;
        }

        .flow-node-title {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }

        .flow-node-description {
            font-size: 13px;
            color: #666;
            margin-bottom: 10px;
        }

        .flow-connections {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e9ecef;
        }

        .flow-connection {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: #666;
            padding: 8px;
            background: #f8f9fa;
            border-radius: 4px;
        }

        .flow-connection-arrow {
            color: #2d5f8d;
            font-weight: bold;
        }

        .flow-connection-label {
            font-weight: 500;
            color: #333;
        }

        .flow-connection-target {
            color: #666;
        }

        .flow-end-node {
            background: #fee;
            border: 2px dashed #dc2626;
            color: #dc2626;
            text-align: center;
            padding: 20px;
            margin: 20px auto;
            max-width: 200px;
            border-radius: 8px;
            font-weight: 600;
        }

        .flow-warning {
            background: #fef3e6;
            border: 1px solid #f59e0b;
            color: #92400e;
            padding: 12px;
            border-radius: 6px;
            margin: 15px 0;
            font-size: 13px;
            text-align: center;
        }

        .flow-diagram-empty {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }

        .flow-diagram-empty-icon {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.5;
        }

        .header-actions {
            display: flex;
            gap: 10px;
        }

        .export-btn {
            padding: 10px 20px;
            background: #059669;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s;
        }

        .export-btn:hover {
            background: #047857;
        }

        .import-btn, .save-btn {
            padding: 10px 20px;
            background: #6366f1;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s;
        }

        .import-btn:hover, .save-btn:hover {
            background: #4f46e5;
        }

        .preview-content {
            flex: 1;
            overflow-y: auto;
            padding: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .flowchart-preview {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 16px rgba(0,0,0,0.1);
            max-width: 600px;
            width: 100%;
            overflow: hidden;
        }

        .preview-banner {
            width: 100%;
            max-height: 200px;
            object-fit: cover;
            display: none;
        }

        .preview-banner.visible {
            display: block;
        }

        .preview-node {
            padding: 40px;
            text-align: center;
        }

        .preview-node h3 {
            font-size: 24px;
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
        }

        .preview-node p {
            font-size: 16px;
            color: #666;
            line-height: 1.6;
            margin-bottom: 30px;
        }

        .preview-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .preview-btn {
            padding: 12px 24px;
            background: #2d5f8d;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s;
        }

        .preview-btn:hover:not(:disabled) {
            background: #1e4466;
        }

        .preview-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .preview-btn.secondary {
            background: #6b7280;
        }

        .preview-btn.secondary:hover:not(:disabled) {
            background: #4b5563;
        }

        .interactive-controls {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 2px solid #e1e4e8;
            display: flex;
            justify-content: center;
            gap: 10px;
        }

        .path-indicator {
            font-size: 12px;
            color: #666;
            margin-top: 15px;
            padding: 8px 12px;
            background: #f8f9fa;
            border-radius: 4px;
            text-align: center;
        }

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: white;
            border-radius: 12px;
            padding: 30px;
            width: 90%;
            max-width: 500px;
            max-height: 80vh;
            overflow-y: auto;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .modal-header h2 {
            font-size: 20px;
            font-weight: 600;
            color: #333;
        }

        .close-modal {
            background: none;
            border: none;
            font-size: 24px;
            color: #666;
            cursor: pointer;
            padding: 0;
            width: 30px;
            height: 30px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 14px;
            font-weight: 500;
            color: #333;
            margin-bottom: 8px;
        }

        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #e1e4e8;
            border-radius: 6px;
            font-size: 14px;
            font-family: inherit;
        }

        .form-group textarea {
            min-height: 80px;
            resize: vertical;
        }

        .form-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            margin-top: 30px;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-primary {
            background: #2d5f8d;
            color: white;
        }

        .btn-primary:hover {
            background: #1e4466;
        }

        .btn-secondary {
            background: #e1e4e8;
            color: #333;
        }

        .btn-secondary:hover {
            background: #d1d5db;
        }

        .connections-editor {
            margin-top: 15px;
        }

        .connection-item {
            display: flex;
            gap: 10px;
            margin-bottom: 10px;
            align-items: center;
        }

        .connection-item input {
            flex: 1;
        }

        .connection-item select {
            flex: 2;
        }

        .remove-connection {
            padding: 6px 12px;
            background: #fee;
            color: #c00;
            border: 1px solid #fcc;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
        }

        .add-connection {
            padding: 8px 16px;
            background: #e6f0f8;
            color: #2d5f8d;
            border: 1px solid #2d5f8d;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;
            margin-top: 10px;
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #666;
        }

        .empty-state-icon {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.5;
        }

        /* Toast Notification */
        .toast {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: #dc2626;
            color: white;
            padding: 16px 24px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            z-index: 10000;
            animation: slideIn 0.3s ease;
            max-width: 400px;
        }

        .toast.success {
            background: #059669;
        }

        .toast.info {
            background: #2563eb;
        }

        @keyframes slideIn {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        /* Confirmation Dialog */
        .confirm-dialog {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            align-items: center;
            justify-content: center;
            z-index: 10001;
        }

        .confirm-dialog.active {
            display: flex;
        }

        .confirm-dialog-content {
            background: white;
            border-radius: 12px;
            padding: 24px;
            max-width: 400px;
            width: 90%;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
        }

        .confirm-dialog-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 12px;
        }

        .confirm-dialog-message {
            font-size: 14px;
            color: #666;
            margin-bottom: 24px;
            line-height: 1.5;
        }

        .confirm-dialog-buttons {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }

        .confirm-dialog-buttons button {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }

        .confirm-dialog-buttons .cancel {
            background: #e1e4e8;
            color: #333;
        }

        .confirm-dialog-buttons .cancel:hover {
            background: #d1d5db;
        }

        .confirm-dialog-buttons .confirm {
            background: #dc2626;
            color: white;
        }

        .confirm-dialog-buttons .confirm:hover {
            background: #b91c1c;
        }

        /* Embed Modal Tabs */
        .embed-tabs {
            display: flex;
            gap: 5px;
            border-bottom: 2px solid #e1e4e8;
            margin-bottom: 20px;
        }

        .embed-tab {
            padding: 10px 20px;
            background: transparent;
            border: none;
            border-bottom: 3px solid transparent;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            color: #666;
            transition: all 0.2s;
        }

        .embed-tab:hover {
            color: #333;
            background: #f8f9fa;
        }

        .embed-tab.active {
            color: #6366f1;
            border-bottom-color: #6366f1;
        }

        .embed-tab-content {
            display: none;
        }

        .embed-tab-content.active {
            display: block;
        }

        .embed-section {
            margin-bottom: 25px;
        }

        .embed-section h3 {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 10px;
            color: #333;
        }

        .embed-section p {
            font-size: 14px;
            color: #666;
            line-height: 1.6;
            margin-bottom: 15px;
        }

        .embed-code-box {
            background: #f8f9fa;
            border: 1px solid #e1e4e8;
            border-radius: 6px;
            padding: 15px;
            font-family: monospace;
            font-size: 12px;
            margin-bottom: 10px;
            position: relative;
        }

        .embed-input {
            width: 100%;
            padding: 8px;
            border: 1px solid #e1e4e8;
            border-radius: 4px;
            font-size: 14px;
            margin-bottom: 15px;
        }

        .deployment-card {
            background: white;
            border: 1px solid #e1e4e8;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
        }

        .deployment-card h4 {
            font-size: 15px;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }

        .deployment-steps {
            list-style: none;
            padding: 0;
        }

        .deployment-steps li {
            padding: 8px 0;
            padding-left: 25px;
            position: relative;
            font-size: 13px;
            color: #666;
            line-height: 1.5;
        }

        .deployment-steps li::before {
            content: attr(data-step);
            position: absolute;
            left: 0;
            top: 8px;
            background: #6366f1;
            color: white;
            width: 18px;
            height: 18px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 600;
        }

        /* Search Results */
        .search-result-card {
            background: white;
            border: 1px solid #e1e4e8;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 12px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .search-result-card:hover {
            border-color: #2d5f8d;
            box-shadow: 0 2px 8px rgba(45,95,141,0.1);
        }

        .search-result-header {
            display: flex;
            gap: 8px;
            align-items: center;
            margin-bottom: 8px;
            flex-wrap: wrap;
        }

        .search-result-title {
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }

        .search-result-snippet {
            font-size: 13px;
            color: #666;
            line-height: 1.5;
            margin-top: 8px;
        }

        .search-highlight {
            background: #fef3e6;
            padding: 2px 4px;
            border-radius: 2px;
            font-weight: 500;
        }

        .search-empty {
            text-align: center;
            padding: 40px 20px;
            color: #999;
        }

        .search-empty-icon {
            font-size: 48px;
            margin-bottom: 10px;
            opacity: 0.5;
        }

        /* Template Cards */
        .template-card {
            background: white;
            border: 1px solid #e1e4e8;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            transition: all 0.2s;
        }

        .template-card:hover {
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .template-card-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 10px;
        }

        .template-card-title {
            font-size: 16px;
            font-weight: 600;
            color: #333;
        }

        .template-card-meta {
            font-size: 12px;
            color: #999;
            margin-bottom: 8px;
        }

        .template-card-description {
            font-size: 14px;
            color: #666;
            line-height: 1.5;
            margin-bottom: 15px;
        }

        .template-card-actions {
            display: flex;
            gap: 8px;
        }

        .template-card-actions button {
            padding: 6px 12px;
            font-size: 13px;
            border-radius: 4px;
            border: none;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s;
        }

        .template-use-btn {
            background: #2d5f8d;
            color: white;
        }

        .template-use-btn:hover {
            background: #1e4466;
        }

        .template-delete-btn {
            background: #fee;
            color: #dc2626;
        }

        .template-delete-btn:hover {
            background: #fcc;
        }

        .template-empty {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }

        /* Resource Links */
        .resource-link-item {
            display: flex;
            gap: 8px;
            margin-bottom: 8px;
        }

        .resource-link-item input {
            font-size: 13px;
        }

        .resource-link-item input:first-child {
            flex: 1;
        }

        .resource-link-item input:nth-child(2) {
            flex: 2;
        }

        .resource-link-display {
            margin-top: 10px;
            padding: 8px;
            background: #f8f9fa;
            border-radius: 4px;
        }

        .resource-link-display a {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 8px;
            background: white;
            border: 1px solid #e1e4e8;
            border-radius: 4px;
            text-decoration: none;
            color: #2d5f8d;
            font-size: 12px;
            margin: 4px;
            transition: all 0.2s;
        }

        .resource-link-display a:hover {
            background: #e6f0f8;
            border-color: #2d5f8d;
        }

        .time-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: #fef3e6;
            color: #d97706;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
        }

        .tips-section {
            background: #e6f0f8;
            border-left: 3px solid #2d5f8d;
            padding: 12px;
            margin-top: 15px;
            border-radius: 4px;
        }

        .tips-section-title {
            font-weight: 600;
            color: #2d5f8d;
            font-size: 13px;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .tips-section-content {
            font-size: 13px;
            color: #495057;
            line-height: 1.5;
        }

        /* Stage Progress Bar */
        .stage-progress-bar {
            background: white;
            border-bottom: 1px solid #e1e4e8;
            padding: 20px 40px;
            overflow-x: auto;
        }

        .stage-progress-container {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            min-width: max-content;
        }

        .stage-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            cursor: pointer;
            transition: all 0.2s;
            position: relative;
        }

        .stage-item:hover {
            transform: translateY(-2px);
        }

        .stage-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            border: 3px solid #e1e4e8;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 14px;
            color: #999;
            transition: all 0.3s;
            position: relative;
        }

        .stage-item.has-nodes .stage-circle {
            border-color: #2d5f8d;
            background: #e6f0f8;
            color: #2d5f8d;
        }

        .stage-item.active .stage-circle {
            border-color: #059669;
            background: #059669;
            color: white;
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.2);
            animation: pulse 2s infinite;
        }

        .stage-item.completed .stage-circle {
            border-color: #059669;
            background: #059669;
            color: white;
        }

        @keyframes pulse {
            0%, 100% { box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.2); }
            50% { box-shadow: 0 0 0 8px rgba(5, 150, 105, 0.1); }
        }

        .stage-label {
            margin-top: 8px;
            font-size: 11px;
            font-weight: 500;
            color: #666;
            text-align: center;
            white-space: nowrap;
        }

        .stage-item.has-nodes .stage-label {
            color: #2d5f8d;
            font-weight: 600;
        }

        .stage-item.active .stage-label {
            color: #059669;
        }

        .stage-connector {
            width: 40px;
            height: 3px;
            background: #e1e4e8;
            margin-bottom: 30px;
        }

        .stage-connector.active {
            background: #2d5f8d;
        }

        .stage-tooltip {
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            background: #333;
            color: white;
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 12px;
            white-space: nowrap;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.2s;
            margin-bottom: 10px;
        }

        .stage-item:hover .stage-tooltip {
            opacity: 1;
        }

        .stage-count {
            position: absolute;
            top: -5px;
            right: -5px;
            background: #dc2626;
            color: white;
            border-radius: 50%;
            width: 18px;
            height: 18px;
            font-size: 10px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                <h1>Flowchart Builder</h1>
                <p>Create interactive flowcharts for iCIMS</p>
            </div>

            <div class="banner-upload">
                <h3>Banner Image</h3>
                <div class="upload-area" id="uploadArea">
                    <div class="upload-icon">📁</div>
                    <div class="upload-text">Click to upload banner image</div>
                    <input type="file" id="bannerInput" accept="image/*" style="display: none;">
                </div>
                <div class="banner-preview" id="bannerPreview">
                    <img id="bannerImg" src="" alt="Banner preview">
                </div>
            </div>

            <div class="nodes-section">
                <div class="nodes-header">
                    <button class="add-node-btn" id="addNodeBtn">+ Add Node</button>
                    <button class="add-node-btn" id="loadTemplateBtn" style="background: #6366f1; margin-top: 10px;">📚 Load Template</button>
                    <div style="display: flex; gap: 8px; margin-top: 10px;">
                        <input type="text" id="jumpInput" placeholder="Go to #..." style="flex: 1; padding: 8px; border: 1px solid #e1e4e8; border-radius: 4px; font-size: 13px;">
                        <button onclick="quickJump()" style="padding: 8px 16px; background: #0891b2; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 13px; font-weight: 500;">Go</button>
                    </div>
                    <div style="display: flex; gap: 8px; margin-top: 10px;">
                        <select id="filterRole" style="flex: 1; padding: 8px; border: 1px solid #e1e4e8; border-radius: 4px; font-size: 12px;">
                            <option value="">All Roles</option>
                        </select>
                        <select id="filterStage" style="flex: 1; padding: 8px; border: 1px solid #e1e4e8; border-radius: 4px; font-size: 12px;">
                            <option value="">All Stages</option>
                        </select>
                    </div>
                    <div id="filterIndicator" style="display: none; margin-top: 8px; padding: 8px; background: #e6f0f8; border-radius: 4px; font-size: 12px; color: #2d5f8d;"></div>
                </div>
                <div class="nodes-list-container" id="nodesList"></div>
            </div>
        </div>

        <!-- Preview Panel -->
        <div class="preview-panel">
            <div class="preview-header">
                <h2>
                    Preview
                    <div class="preview-mode-toggle">
                        <button id="staticModeBtn" class="active">Static</button>
                        <button id="interactiveModeBtn">Interactive</button>
                        <button id="diagramModeBtn">Diagram</button>
                    </div>
                </h2>
                <div class="header-actions">
                    <input type="file" id="importInput" accept=".json" style="display: none;">
                    <button class="import-btn" id="searchBtn" style="background: #0891b2;">🔍 Search</button>
                    <button class="import-btn" id="importBtn">Import Project</button>
                    <button class="save-btn" id="saveProjectBtn">Save Project</button>
                    <button class="save-btn" id="saveTemplateBtn" style="background: #d97706;">📋 Save Template</button>
                    <button class="export-btn" id="exportBtn">Export HTML</button>
                    <button class="export-btn" id="embedBtn" style="background: #6366f1;">Get Embed Code</button>
                </div>
            </div>
            <div class="stage-progress-bar" id="stageProgressBar" style="display: none;">
                <div class="stage-progress-container"></div>
            </div>
            <div class="preview-content">
                <div class="flowchart-preview">
                    <img class="preview-banner" id="previewBanner" src="" alt="">
                    <div class="preview-node" id="previewNode">
                        <div class="empty-state">
                            <div class="empty-state-icon">📊</div>
                            <p>Add nodes to see preview</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Node Modal -->
    <div class="modal" id="editModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modalTitle">Add Node</h2>
                <button class="close-modal" id="closeModal">&times;</button>
            </div>
            <div id="nodeForm">
                <div class="form-group">
                    <label>Node Type</label>
                    <select id="nodeType">
                        <option value="info">Information</option>
                        <option value="decision">Decision</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Title</label>
                    <input type="text" id="nodeTitle" placeholder="Enter node title">
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea id="nodeDescription" placeholder="Enter description"></textarea>
                </div>
                <div class="form-group">
                    <label>Assigned To</label>
                    <select id="nodeRole">
                        <option value="">Select role...</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Workflow Stage</label>
                    <select id="nodeStage">
                        <option value="">Select stage...</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Estimated Time (optional)</label>
                    <input type="text" id="nodeTime" placeholder="e.g., 5 minutes, 2 hours, 1-2 days">
                </div>
                <div class="form-group">
                    <label>Tips & Best Practices (optional)</label>
                    <textarea id="nodeTips" placeholder="Add helpful tips or notes for this step..." style="min-height: 60px;"></textarea>
                </div>
                <div class="form-group">
                    <label>Resource Links (optional)</label>
                    <div id="resourceLinksList"></div>
                    <button type="button" class="add-connection" onclick="addResourceLink()">+ Add Resource Link</button>
                </div>
                <div class="form-group" id="connectionsGroup">
                    <label>Connections</label>
                    <div id="connectionsList"></div>
                    <button type="button" class="add-connection" id="addConnectionBtn">+ Add Connection</button>
                </div>
                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" id="cancelBtn">Cancel</button>
                    <button type="button" class="btn btn-primary" id="saveNodeBtn">Save Node</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Confirmation Dialog -->
    <div class="confirm-dialog" id="confirmDialog">
        <div class="confirm-dialog-content">
            <div class="confirm-dialog-title" id="confirmTitle">Confirm Action</div>
            <div class="confirm-dialog-message" id="confirmMessage">Are you sure?</div>
            <div class="confirm-dialog-buttons">
                <button class="cancel" id="confirmCancel">Cancel</button>
                <button class="confirm" id="confirmOk">Confirm</button>
            </div>
        </div>
    </div>

    <!-- Embed Modal -->
    <div class="modal" id="embedModal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h2>Embed Your Flowchart</h2>
                <button class="close-modal" id="closeEmbedModal">&times;</button>
            </div>
            <div id="embedContent"></div>
        </div>
    </div>

    <!-- Search Modal -->
    <div class="modal" id="searchModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h2>Search Nodes</h2>
                <button class="close-modal" id="closeSearchModal">&times;</button>
            </div>
            <div style="padding: 0 30px 30px 30px;">
                <input type="text" id="searchInput" placeholder="Search by title, description, role, or stage..." style="width: 100%; padding: 12px; font-size: 15px; border: 2px solid #e1e4e8; border-radius: 6px; margin-bottom: 20px;">
                <div id="searchResults"></div>
            </div>
        </div>
    </div>

    <!-- Template Save Modal -->
    <div class="modal" id="templateSaveModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h2>Save as Template</h2>
                <button class="close-modal" id="closeTemplateSaveModal">&times;</button>
            </div>
            <div style="padding: 0 30px 30px 30px;">
                <div class="form-group">
                    <label>Template Name</label>
                    <input type="text" id="templateName" placeholder="e.g., Standard Requisition Workflow" style="width: 100%; padding: 10px; border: 1px solid #e1e4e8; border-radius: 6px;">
                </div>
                <div class="form-group">
                    <label>Description (optional)</label>
                    <textarea id="templateDescription" placeholder="Describe what this template is for..." style="width: 100%; min-height: 80px; padding: 10px; border: 1px solid #e1e4e8; border-radius: 6px;"></textarea>
                </div>
                <div style="background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 20px;">
                    <strong>Template includes:</strong>
                    <ul style="margin: 10px 0 0 20px; font-size: 14px; color: #666;">
                        <li id="templateNodeCount"></li>
                        <li>All roles and stages</li>
                        <li>Node connections</li>
                        <li>Banner image (if set)</li>
                    </ul>
                </div>
                <div class="form-actions" style="display: flex; gap: 10px; justify-content: flex-end;">
                    <button class="btn btn-secondary" onclick="document.getElementById('templateSaveModal').classList.remove('active')">Cancel</button>
                    <button class="btn btn-primary" onclick="saveTemplate()">Save Template</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Template Library Modal -->
    <div class="modal" id="templateLibraryModal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h2>Template Library</h2>
                <button class="close-modal" id="closeTemplateLibraryModal">&times;</button>
            </div>
            <div id="templateLibraryContent" style="padding: 0 30px 30px 30px;"></div>
        </div>
    </div>

    <script>
        let nodes = [];
        let bannerDataUrl = null;
        let editingNodeId = null;
        let selectedNodeId = null;
        let draggedNodeId = null;
        let startNodeId = null;
        let previewMode = 'static'; // 'static', 'interactive', or 'diagram'
        let interactiveCurrentNodeId = null;
        let interactiveHistory = [];
        let activeFilters = { role: '', stage: '' };

        // Role and Stage definitions
        const roles = [
            'Recruiter',
            'Hiring Manager',
            'Coordinator',
            'TA Leadership',
            'HR/Compliance',
            'Candidate',
            'System',
            'Any'
        ];

        const stages = [
            'Planning',
            'Sourcing',
            'Screening',
            'Interviewing',
            'Selection',
            'Offer',
            'Onboarding',
            'General'
        ];

        const roleColors = {
            'Recruiter': '#2d5f8d',
            'Hiring Manager': '#059669',
            'Coordinator': '#6366f1',
            'TA Leadership': '#d97706',
            'HR/Compliance': '#dc2626',
            'Candidate': '#0891b2',
            'System': '#6b7280',
            'Any': '#9ca3af'
        };

        // Stage order for numbering
        const stageOrder = {
            'Planning': 1,
            'Sourcing': 2,
            'Screening': 3,
            'Interviewing': 4,
            'Selection': 5,
            'Offer': 6,
            'Onboarding': 7,
            'General': 8
        };

        // Calculate hierarchical node numbers
        function calculateNodeNumbers() {
            // Group nodes by stage
            const nodesByStage = {};
            nodes.forEach(node => {
                const stage = node.stage || 'General';
                if (!nodesByStage[stage]) {
                    nodesByStage[stage] = [];
                }
                nodesByStage[stage].push(node);
            });

            // Assign numbers within each stage
            nodes.forEach(node => {
                const stage = node.stage || 'General';
                const stageNum = stageOrder[stage] || 8;
                const stageNodes = nodesByStage[stage];
                const positionInStage = stageNodes.indexOf(node) + 1;
                node.calculatedNumber = `${stageNum}.${positionInStage}`;
            });
        }

        // Toast notification system
        function showToast(message, type = 'error') {
            const toast = document.createElement('div');
            toast.className = `toast ${type}`;
            toast.textContent = message;
            document.body.appendChild(toast);
            
            setTimeout(() => {
                toast.remove();
            }, 3000);
        }

        // Custom confirm dialog
        function showConfirm(title, message) {
            return new Promise((resolve) => {
                const dialog = document.getElementById('confirmDialog');
                document.getElementById('confirmTitle').textContent = title;
                document.getElementById('confirmMessage').textContent = message;
                dialog.classList.add('active');

                const handleConfirm = () => {
                    dialog.classList.remove('active');
                    cleanup();
                    resolve(true);
                };

                const handleCancel = () => {
                    dialog.classList.remove('active');
                    cleanup();
                    resolve(false);
                };

                const cleanup = () => {
                    document.getElementById('confirmOk').removeEventListener('click', handleConfirm);
                    document.getElementById('confirmCancel').removeEventListener('click', handleCancel);
                };

                document.getElementById('confirmOk').addEventListener('click', handleConfirm);
                document.getElementById('confirmCancel').addEventListener('click', handleCancel);
            });
        }

        // Banner upload
        document.getElementById('uploadArea').addEventListener('click', () => {
            document.getElementById('bannerInput').click();
        });

        document.getElementById('bannerInput').addEventListener('change', (e) => {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = (e) => {
                    bannerDataUrl = e.target.result;
                    document.getElementById('bannerImg').src = bannerDataUrl;
                    document.getElementById('bannerPreview').style.display = 'block';
                    document.getElementById('uploadArea').classList.add('has-file');
                    document.getElementById('uploadArea').querySelector('.upload-text').textContent = file.name;
                    updatePreview();
                };
                reader.readAsDataURL(file);
            }
        });

        // Add node button
        document.getElementById('addNodeBtn').addEventListener('click', () => {
            editingNodeId = null;
            document.getElementById('modalTitle').textContent = 'Add Node';
            document.getElementById('nodeType').value = 'info';
            document.getElementById('nodeTitle').value = '';
            document.getElementById('nodeDescription').value = '';
            document.getElementById('nodeTime').value = '';
            document.getElementById('nodeTips').value = '';
            
            // Populate role dropdown
            const roleSelect = document.getElementById('nodeRole');
            roleSelect.innerHTML = '<option value="">Select role...</option>';
            roles.forEach(role => {
                roleSelect.innerHTML += `<option value="${role}">${role}</option>`;
            });
            
            // Populate stage dropdown
            const stageSelect = document.getElementById('nodeStage');
            stageSelect.innerHTML = '<option value="">Select stage...</option>';
            stages.forEach(stage => {
                stageSelect.innerHTML += `<option value="${stage}">${stage}</option>`;
            });
            
            // Clear resource links
            document.getElementById('resourceLinksList').innerHTML = '';
            
            // Show description field for info nodes
            const descGroup = document.querySelector('#nodeDescription').closest('.form-group');
            descGroup.style.display = 'block';
            
            document.getElementById('connectionsList').innerHTML = '';
            updateConnectionsEditor();
            document.getElementById('editModal').classList.add('active');
        });

        // Close modal
        document.getElementById('closeModal').addEventListener('click', () => {
            document.getElementById('editModal').classList.remove('active');
        });

        document.getElementById('cancelBtn').addEventListener('click', () => {
            document.getElementById('editModal').classList.remove('active');
        });

        // Node type change
        document.getElementById('nodeType').addEventListener('change', (e) => {
            const descGroup = document.querySelector('#nodeDescription').closest('.form-group');
            if (e.target.value === 'decision') {
                descGroup.style.display = 'none';
            } else {
                descGroup.style.display = 'block';
            }
            updateConnectionsEditor();
        });

        // Add connection
        document.getElementById('addConnectionBtn').addEventListener('click', () => {
            addConnectionField();
        });

        // Save node
        document.getElementById('saveNodeBtn').addEventListener('click', () => {
            const title = document.getElementById('nodeTitle').value.trim();
            const nodeType = document.getElementById('nodeType').value;
            
            if (!title) {
                showToast('Please enter a title for the node');
                return;
            }

            // Validate decision nodes
            if (nodeType === 'decision') {
                const connectionItems = document.querySelectorAll('.connection-item');
                
                // Check minimum branches
                if (connectionItems.length < 2) {
                    showToast('Decision nodes must have at least 2 branches');
                    return;
                }
                
                // Check all branches have labels and targets
                let hasEmptyLabel = false;
                let hasEmptyTarget = false;
                connectionItems.forEach(item => {
                    const input = item.querySelector('input');
                    const select = item.querySelector('select');
                    if (!input || !input.value.trim()) {
                        hasEmptyLabel = true;
                    }
                    if (!select || !select.value) {
                        hasEmptyTarget = true;
                    }
                });
                
                if (hasEmptyLabel) {
                    showToast('All decision branches must have labels');
                    return;
                }
                
                if (hasEmptyTarget) {
                    showToast('All decision branches must have a target');
                    return;
                }
            }
            
            const nodeData = {
                id: editingNodeId || Date.now().toString(),
                type: nodeType,
                title: title,
                description: nodeType === 'decision' ? '' : document.getElementById('nodeDescription').value,
                role: document.getElementById('nodeRole').value || 'Any',
                stage: document.getElementById('nodeStage').value || 'General',
                estimatedTime: document.getElementById('nodeTime').value.trim(),
                tips: document.getElementById('nodeTips').value.trim(),
                resourceLinks: [],
                connections: []
            };

            // Collect resource links
            const linkItems = document.querySelectorAll('.resource-link-item');
            linkItems.forEach(item => {
                const textInput = item.querySelector('input:first-child');
                const urlInput = item.querySelector('input:nth-child(2)');
                if (textInput && urlInput && textInput.value.trim() && urlInput.value.trim()) {
                    nodeData.resourceLinks.push({
                        text: textInput.value.trim(),
                        url: urlInput.value.trim()
                    });
                }
            });

            const connectionItems = document.querySelectorAll('.connection-item');
            connectionItems.forEach(item => {
                const inputs = item.querySelectorAll('input');
                const selectField = item.querySelector('select');
                const target = selectField ? selectField.value : '';
                
                if (target) {
                    let label = '';
                    let description = '';
                    
                    if (nodeData.type === 'decision') {
                        label = inputs[0] ? inputs[0].value.trim() : '';
                        description = inputs[1] ? inputs[1].value.trim() : '';
                    } else {
                        description = inputs[0] ? inputs[0].value.trim() : '';
                    }
                    
                    nodeData.connections.push({ label, target, description });
                }
            });

            if (editingNodeId) {
                const index = nodes.findIndex(n => n.id === editingNodeId);
                nodes[index] = nodeData;
            } else {
                nodes.push(nodeData);
                // Auto-select newly added node
                selectedNodeId = nodeData.id;
                // Set as start node if it's the first node
                if (nodes.length === 1) {
                    startNodeId = nodeData.id;
                }
            }

            document.getElementById('editModal').classList.remove('active');
            renderNodesList();
            updatePreview();
            saveToLocalStorage();
        });

        function addConnectionField(label = '', target = '', description = '') {
            const container = document.getElementById('connectionsList');
            const item = document.createElement('div');
            item.className = 'connection-item';
            item.style.flexDirection = 'column';
            item.style.gap = '8px';
            
            const nodeType = document.getElementById('nodeType').value;
            
            item.innerHTML = `
                <div style="display: flex; gap: 8px; width: 100%;">
                    ${nodeType === 'decision' ? 
                        `<input type="text" placeholder="Branch name (e.g., Yes, Approved)" value="${label}" required style="flex: 1;">` : 
                        ''}
                    <select style="flex: 2;">
                        <option value="">Select next node...</option>
                        ${nodes.filter(n => n.id !== editingNodeId).map(n => 
                            `<option value="${n.id}" ${n.id === target ? 'selected' : ''}>${n.title}</option>`
                        ).join('')}
                        <option value="END" ${target === 'END' ? 'selected' : ''}>END</option>
                    </select>
                    <button type="button" class="remove-connection">×</button>
                </div>
                <input type="text" placeholder="Optional: Describe when this path is taken..." value="${description}" 
                    style="width: 100%; font-size: 13px; font-style: italic; color: #666;">
            `;

            item.querySelector('.remove-connection').addEventListener('click', () => {
                item.remove();
                updateBranchButtonState();
            });

            container.appendChild(item);
            updateBranchButtonState();
        }

        function updateConnectionsEditor() {
            const nodeType = document.getElementById('nodeType').value;
            document.getElementById('connectionsList').innerHTML = '';
            
            if (nodeType === 'info') {
                // Info nodes get one simple connection
                addConnectionField();
            } else {
                // Decision nodes start with no branches - user must add them
                updateBranchButtonState();
            }
        }

        function updateBranchButtonState() {
            const nodeType = document.getElementById('nodeType').value;
            const addBtn = document.getElementById('addConnectionBtn');
            
            if (nodeType === 'decision') {
                const count = document.querySelectorAll('.connection-item').length;
                addBtn.textContent = `+ Add Branch (${count}/5)`;
                addBtn.disabled = count >= 5;
                addBtn.style.display = 'block';
            } else {
                addBtn.textContent = '+ Add Connection';
                addBtn.disabled = false;
                addBtn.style.display = 'block';
            }
        }

        function renderNodesList() {
            const container = document.getElementById('nodesList');
            
            if (nodes.length === 0) {
                container.innerHTML = '<div class="empty-state"><div class="empty-state-icon">📝</div><p>No nodes yet. Click "Add Node" to start building your flowchart.</p></div>';
                return;
            }

            container.innerHTML = nodes.map((node, index) => `
                <div class="node-item ${node.id === selectedNodeId ? 'active' : ''} ${node.id === startNodeId ? 'start-node' : ''}" data-id="${node.id}" draggable="true">
                    <div class="node-header">
                        <span class="node-type-badge ${node.type}">
                            <span class="drag-handle">⋮⋮</span> ${node.type}
                        </span>
                        <div class="node-actions">
                            <button class="start-btn" title="Set as start node">★</button>
                            <button class="duplicate-btn" title="Duplicate node">⎘</button>
                            <button class="edit-btn">Edit</button>
                            <button class="delete-btn delete">Delete</button>
                        </div>
                    </div>
                    <div class="node-title">${node.title}</div>
                    ${node.type !== 'decision' ? `<div class="node-description">${node.description}</div>` : ''}
                    <div class="node-connections">
                        ${node.connections.length > 0 ? 
                            node.connections.map(c => {
                                const targetNode = nodes.find(n => n.id === c.target);
                                const targetNumber = targetNode ? `[${targetNode.calculatedNumber || '?'}]` : '';
                                const targetTitle = getNodeTitle(c.target);
                                
                                if (node.type === 'decision') {
                                    return `→ <strong>${c.label}</strong>: ${targetNumber} ${targetTitle}`;
                                } else {
                                    return `→ ${c.label ? c.label + ': ' : ''}${targetNumber} ${targetTitle}`;
                                }
                            }).join('<br>') 
                            : 'No connections'}
                    </div>
                </div>
            `).join('');

            // Add click handlers for node selection and actions
            document.querySelectorAll('.node-item').forEach(item => {
                const nodeId = item.dataset.id; // Store ID locally to avoid closure issues
                
                // Start node button
                item.querySelector('.start-btn').addEventListener('click', (e) => {
                    e.stopPropagation();
                    setStartNode(nodeId);
                });
                
                // Duplicate button
                item.querySelector('.duplicate-btn').addEventListener('click', (e) => {
                    e.stopPropagation();
                    duplicateNode(nodeId);
                });
                
                // Edit button
                item.querySelector('.edit-btn').addEventListener('click', (e) => {
                    e.stopPropagation();
                    editNode(nodeId);
                });

                // Delete button
                item.querySelector('.delete-btn').addEventListener('click', (e) => {
                    e.stopPropagation();
                    deleteNode(nodeId);
                });

                // Node selection
                item.addEventListener('click', (e) => {
                    if (!e.target.closest('button')) {
                        selectedNodeId = nodeId;
                        renderNodesList();
                        updatePreview();
                    }
                });

                // Drag and drop handlers
                item.addEventListener('dragstart', handleDragStart);
                item.addEventListener('dragover', handleDragOver);
                item.addEventListener('drop', handleDrop);
                item.addEventListener('dragend', handleDragEnd);
            });
        }

        function getNodeTitle(nodeId) {
            if (nodeId === 'END') return 'END';
            const node = nodes.find(n => n.id === nodeId);
            return node ? node.title : 'Unknown';
        }

        function getIncomingConnections(nodeId) {
            const incoming = [];
            nodes.forEach(node => {
                node.connections.forEach(conn => {
                    if (conn.target === nodeId) {
                        incoming.push(node.title);
                    }
                });
            });
            return incoming;
        }

        function editNode(id) {
            editingNodeId = id;
            const node = nodes.find(n => n.id === id);
            
            document.getElementById('modalTitle').textContent = 'Edit Node';
            document.getElementById('nodeType').value = node.type;
            document.getElementById('nodeTitle').value = node.title;
            document.getElementById('nodeDescription').value = node.description;
            document.getElementById('nodeTime').value = node.estimatedTime || '';
            document.getElementById('nodeTips').value = node.tips || '';
            
            // Populate and set role dropdown
            const roleSelect = document.getElementById('nodeRole');
            roleSelect.innerHTML = '<option value="">Select role...</option>';
            roles.forEach(role => {
                const selected = node.role === role ? 'selected' : '';
                roleSelect.innerHTML += `<option value="${role}" ${selected}>${role}</option>`;
            });
            
            // Populate and set stage dropdown
            const stageSelect = document.getElementById('nodeStage');
            stageSelect.innerHTML = '<option value="">Select stage...</option>';
            stages.forEach(stage => {
                const selected = node.stage === stage ? 'selected' : '';
                stageSelect.innerHTML += `<option value="${stage}" ${selected}>${stage}</option>`;
            });
            
            // Load resource links
            document.getElementById('resourceLinksList').innerHTML = '';
            if (node.resourceLinks && node.resourceLinks.length > 0) {
                node.resourceLinks.forEach(link => {
                    addResourceLink(link.text, link.url);
                });
            }
            
            // Show/hide description based on node type
            const descGroup = document.querySelector('#nodeDescription').closest('.form-group');
            if (node.type === 'decision') {
                descGroup.style.display = 'none';
            } else {
                descGroup.style.display = 'block';
            }
            
            document.getElementById('connectionsList').innerHTML = '';
            node.connections.forEach(conn => {
                addConnectionField(conn.label, conn.target, conn.description || '');
            });

            if (node.connections.length === 0) {
                updateConnectionsEditor();
            } else {
                updateBranchButtonState();
            }

            document.getElementById('editModal').classList.add('active');
        }

        function deleteNode(id) {
            showConfirm('Delete Node', 'Are you sure you want to delete this node?').then(confirmed => {
                if (confirmed) {
                    nodes = nodes.filter(n => n.id !== id);
                    
                    // Clean up connections in other nodes that reference this deleted node
                    nodes.forEach(node => {
                        node.connections = node.connections.filter(conn => conn.target !== id);
                    });
                    
                    // Update start node if deleted
                    if (startNodeId === id) {
                        startNodeId = nodes.length > 0 ? nodes[0].id : null;
                    }
                    
                    // Update selected node
                    if (selectedNodeId === id) {
                        selectedNodeId = nodes.length > 0 ? nodes[0].id : null;
                    }
                    
                    renderNodesList();
                    updatePreview();
                    saveToLocalStorage();
                    showToast('Node deleted successfully', 'success');
                }
            });
        }

        function setStartNode(id) {
            startNodeId = id;
            
            // Move start node to the top of the array
            const nodeIndex = nodes.findIndex(n => n.id === id);
            if (nodeIndex > 0) {
                const [startNode] = nodes.splice(nodeIndex, 1);
                nodes.unshift(startNode);
            }
            
            renderNodesList();
            updatePreview();
            saveToLocalStorage();
            showToast('Start node set and moved to top', 'success');
        }

        // Add resource link function
        window.addResourceLink = function(text = '', url = '') {
            const container = document.getElementById('resourceLinksList');
            const item = document.createElement('div');
            item.className = 'resource-link-item';
            
            item.innerHTML = `
                <input type="text" placeholder="Link text" value="${text}">
                <input type="url" placeholder="https://example.com" value="${url}">
                <button type="button" class="remove-connection" onclick="this.parentElement.remove()">×</button>
            `;
            
            container.appendChild(item);
        };

        function duplicateNode(id) {
            const originalNode = nodes.find(n => n.id === id);
            if (!originalNode) return;

            // Create a copy with new ID
            const newNode = {
                id: Date.now().toString(),
                type: originalNode.type,
                title: originalNode.title + ' (Copy)',
                description: originalNode.description,
                role: originalNode.role || 'Any',
                stage: originalNode.stage || 'General',
                estimatedTime: originalNode.estimatedTime || '',
                tips: originalNode.tips || '',
                resourceLinks: originalNode.resourceLinks ? [...originalNode.resourceLinks] : [],
                connections: [...originalNode.connections] // Copy connections array
            };

            // Find the position after the original node
            const originalIndex = nodes.findIndex(n => n.id === id);
            nodes.splice(originalIndex + 1, 0, newNode);

            // Select the new node
            selectedNodeId = newNode.id;

            renderNodesList();
            updatePreview();
            saveToLocalStorage();
            showToast('Node duplicated successfully', 'success');
        }

        // Drag and drop handlers
        function handleDragStart(e) {
            draggedNodeId = e.currentTarget.dataset.id;
            e.currentTarget.classList.add('dragging');
            e.dataTransfer.effectAllowed = 'move';
        }

        function handleDragOver(e) {
            e.preventDefault();
            e.dataTransfer.dropEffect = 'move';
            
            const afterElement = e.currentTarget;
            if (afterElement.dataset.id !== draggedNodeId) {
                afterElement.classList.add('drag-over');
            }
        }

        function handleDrop(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const dropTargetId = e.currentTarget.dataset.id;
            
            if (draggedNodeId && dropTargetId && draggedNodeId !== dropTargetId) {
                const draggedIndex = nodes.findIndex(n => n.id === draggedNodeId);
                const dropIndex = nodes.findIndex(n => n.id === dropTargetId);
                
                // Remove dragged node and insert at new position
                const [draggedNode] = nodes.splice(draggedIndex, 1);
                nodes.splice(dropIndex, 0, draggedNode);
                
                renderNodesList();
                updatePreview();
            }
        }

        function handleDragEnd(e) {
            e.currentTarget.classList.remove('dragging');
            document.querySelectorAll('.node-item').forEach(item => {
                item.classList.remove('drag-over');
            });
            draggedNodeId = null;
        }

        function renderStageProgress() {
            const container = document.querySelector('.stage-progress-container');
            if (!container) return;
            
            const progressBar = document.getElementById('stageProgressBar');
            
            // Only show in diagram mode
            if (previewMode !== 'diagram' || nodes.length === 0) {
                progressBar.style.display = 'none';
                return;
            }
            
            progressBar.style.display = 'block';
            
            // Count nodes per stage
            const stageCounts = {};
            stages.forEach(stage => stageCounts[stage] = 0);
            nodes.forEach(node => {
                const stage = node.stage || 'General';
                stageCounts[stage]++;
            });
            
            // Determine current stage (most recent selected node's stage)
            const currentNode = nodes.find(n => n.id === selectedNodeId);
            const currentStage = currentNode ? (currentNode.stage || 'General') : null;
            
            // Determine completed stages (before current)
            const currentStageIndex = stages.indexOf(currentStage);
            
            let html = '';
            stages.forEach((stage, index) => {
                const count = stageCounts[stage];
                const hasNodes = count > 0;
                const isActive = stage === currentStage;
                const isCompleted = currentStageIndex > -1 && index < currentStageIndex && hasNodes;
                
                // Add connector line (except before first)
                if (index > 0) {
                    const connectorActive = hasNodes && stageCounts[stages[index - 1]] > 0;
                    html += `<div class="stage-connector ${connectorActive ? 'active' : ''}"></div>`;
                }
                
                // Stage item
                html += `
                    <div class="stage-item ${hasNodes ? 'has-nodes' : ''} ${isActive ? 'active' : ''} ${isCompleted ? 'completed' : ''}" 
                        data-stage="${stage}"
                        onclick="filterByStage('${stage}')">
                        <div class="stage-circle">
                            ${isCompleted ? '✓' : (index + 1)}
                            ${hasNodes ? `<span class="stage-count">${count}</span>` : ''}
                        </div>
                        <div class="stage-label">${stage}</div>
                        <div class="stage-tooltip">${count} node${count !== 1 ? 's' : ''} in ${stage}</div>
                    </div>
                `;
            });
            
            container.innerHTML = html;
        }

        // Add filter by stage function
        window.filterByStage = function(stage) {
            document.getElementById('filterStage').value = stage;
            applyFilters();
            
            // Switch to static or diagram view if in interactive
            if (previewMode === 'interactive') {
                document.getElementById('diagramModeBtn').click();
            }
            
            showToast(`Filtered to ${stage} stage`, 'info');
        };

        function updatePreview() {
            renderStageProgress();
            const previewBanner = document.getElementById('previewBanner');
            const previewNode = document.getElementById('previewNode');

            // Update banner
            if (bannerDataUrl) {
                previewBanner.src = bannerDataUrl;
                previewBanner.classList.add('visible');
            } else {
                previewBanner.classList.remove('visible');
            }

            if (previewMode === 'static') {
                renderStaticPreview(previewNode);
            } else if (previewMode === 'interactive') {
                renderInteractivePreview(previewNode);
            } else if (previewMode === 'diagram') {
                renderDiagramView(previewNode);
            }
        }

        function renderDiagramView(container) {
            if (nodes.length === 0) {
                container.innerHTML = `
                    <div class="flow-diagram-empty">
                        <div class="flow-diagram-empty-icon">📊</div>
                        <p>Add nodes to see the flow diagram</p>
                    </div>
                `;
                return;
            }

            // Calculate numbers before rendering
            calculateNodeNumbers();

            // Build the flow diagram
            let html = '<div class="flow-diagram"><div class="flow-diagram-container">';

            // Validation warnings
            const warnings = validateFlow();
            if (warnings.length > 0) {
                html += '<div class="flow-warning">';
                html += '⚠️ ' + warnings.join(' • ');
                html += '</div>';
            }

            // Render nodes in order
            nodes.forEach((node, index) => {
                const isStart = node.id === startNodeId;
                const isSelected = node.id === selectedNodeId;
                const roleColor = roleColors[node.role] || roleColors['Any'];
                const nodeNumber = node.calculatedNumber || '?';
                
                html += `
                    <div class="flow-node ${isStart ? 'start' : ''} ${isSelected ? 'selected' : ''}" data-node-id="${node.id}">
                        <div class="flow-node-header">
                            <div style="display: flex; gap: 5px; flex-wrap: wrap; align-items: center; margin-bottom: 8px;">
                                <span class="node-number-badge">[${nodeNumber}]</span>
                                <span class="flow-node-type ${node.type}">${node.type}</span>
                                <span class="role-badge" style="background-color: ${roleColor};">${node.role || 'Any'}</span>
                                <span class="stage-badge">${node.stage || 'General'}</span>
                            </div>
                        </div>
                        <div class="flow-node-title">${node.title}</div>
                `;

                // Only show description for non-decision nodes
                if (node.type !== 'decision') {
                    html += `<div class="flow-node-description">${node.description || 'No description'}</div>`;
                }

                if (node.connections.length > 0) {
                    html += '<div class="flow-connections">';
                    node.connections.forEach(conn => {
                        const targetNode = nodes.find(n => n.id === conn.target);
                        const targetTitle = conn.target === 'END' ? 'END' : (targetNode ? targetNode.title : 'Unknown');
                        const targetNumber = targetNode ? targetNode.calculatedNumber : '';
                        
                        if (node.type === 'decision') {
                            // For decisions, emphasize the branch label
                            html += `
                                <div class="flow-connection">
                                    <span class="flow-connection-arrow">↓</span>
                                    <span class="flow-connection-label">${conn.label}</span>
                                    <span class="flow-connection-arrow">→</span>
                                    <span class="flow-connection-target">${targetNumber ? '['+targetNumber+'] ' : ''}${targetTitle}</span>
                                    ${conn.description ? `<div style="font-size: 11px; color: #888; font-style: italic; margin-top: 4px;">${conn.description}</div>` : ''}
                                </div>
                            `;
                        } else {
                            html += `
                                <div class="flow-connection">
                                    <span class="flow-connection-arrow">↓</span>
                                    ${conn.label ? `<span class="flow-connection-label">${conn.label}:</span>` : ''}
                                    <span class="flow-connection-target">${targetNumber ? '['+targetNumber+'] ' : ''}${targetTitle}</span>
                                </div>
                            `;
                        }
                    });
                    html += '</div>';
                } else {
                    html += '<div class="flow-connections"><div class="flow-connection">⚠️ No connections</div></div>';
                }

                html += '</div>';

                // Show END node if this node connects to END
                if (node.connections.some(c => c.target === 'END')) {
                    html += '<div class="flow-end-node">● END ●</div>';
                }
            });

            html += '</div></div>';
            container.innerHTML = html;

            // Add click handlers to flow nodes
            container.querySelectorAll('.flow-node').forEach(nodeEl => {
                nodeEl.addEventListener('click', () => {
                    selectedNodeId = nodeEl.dataset.nodeId;
                    renderNodesList();
                    updatePreview();
                });
            });
        }

        function validateFlow() {
            const warnings = [];

            // Check for start node
            if (!startNodeId) {
                warnings.push('No start node set');
            }

            // Check for orphaned nodes (nodes that nothing connects to, except start)
            const referencedNodes = new Set();
            nodes.forEach(node => {
                node.connections.forEach(conn => {
                    if (conn.target !== 'END') {
                        referencedNodes.add(conn.target);
                    }
                });
            });

            const orphanedNodes = nodes.filter(node => 
                node.id !== startNodeId && !referencedNodes.has(node.id)
            );

            if (orphanedNodes.length > 0) {
                warnings.push(`${orphanedNodes.length} unreachable node(s): ${orphanedNodes.map(n => n.title).join(', ')}`);
            }

            // Check for nodes with no connections (dead ends that don't explicitly end)
            const deadEnds = nodes.filter(node => 
                node.connections.length === 0
            );
            if (deadEnds.length > 0) {
                warnings.push(`${deadEnds.length} dead end(s): ${deadEnds.map(n => n.title).join(', ')}`);
            }

            // Check for broken connections
            const brokenConnections = [];
            nodes.forEach(node => {
                node.connections.forEach(conn => {
                    if (conn.target !== 'END' && !nodes.find(n => n.id === conn.target)) {
                        brokenConnections.push(`${node.title} → ${conn.label || 'connection'}`);
                    }
                });
            });

            if (brokenConnections.length > 0) {
                warnings.push(`${brokenConnections.length} broken connection(s): ${brokenConnections.join(', ')}`);
            }

            // Check for decision nodes with fewer than 2 branches
            const invalidDecisions = nodes.filter(node => 
                node.type === 'decision' && node.connections.length < 2
            );
            if (invalidDecisions.length > 0) {
                warnings.push(`${invalidDecisions.length} decision(s) with < 2 branches: ${invalidDecisions.map(n => n.title).join(', ')}`);
            }

            return warnings;
        }

        function renderStaticPreview(container) {
            // Static preview shows the selected node
            const node = nodes.find(n => n.id === selectedNodeId) || nodes[0];
            
            if (!node) {
                container.innerHTML = '<div class="empty-state"><div class="empty-state-icon">📊</div><p>Add nodes to see preview</p></div>';
                return;
            }

            // Calculate numbers
            calculateNodeNumbers();
            
            const roleColor = roleColors[node.role] || roleColors['Any'];
            const nodeNumber = node.calculatedNumber || '?';

            let buttonsHtml = '';
            if (node.type === 'decision' && node.connections.length > 0) {
                buttonsHtml = node.connections.map(c => 
                    `<button class="preview-btn" disabled>${c.label}</button>`
                ).join('');
            } else if (node.type === 'info' && node.connections.length > 0) {
                buttonsHtml = '<button class="preview-btn" disabled>Next</button>';
            }

            if (node.connections.some(c => c.target === 'END') || node.connections.length === 0) {
                buttonsHtml += '<button class="preview-btn secondary" disabled>Start Over</button>';
            } else {
                buttonsHtml = '<button class="preview-btn secondary" disabled>Back</button>' + buttonsHtml;
            }

            const descriptionHtml = node.type !== 'decision' && node.description ? `<p>${node.description}</p>` : '';
            
            // Time estimate
            const timeHtml = node.estimatedTime ? `<div class="time-badge">⏱️ ${node.estimatedTime}</div>` : '';
            
            // Tips
            const tipsHtml = node.tips ? `
                <div class="tips-section">
                    <div class="tips-section-title">💡 Tips & Best Practices</div>
                    <div class="tips-section-content">${node.tips}</div>
                </div>
            ` : '';
            
            // Resource links
            const linksHtml = node.resourceLinks && node.resourceLinks.length > 0 ? `
                <div class="resource-link-display">
                    ${node.resourceLinks.map(link => 
                        `<a href="${link.url}" target="_blank" rel="noopener">🔗 ${link.text}</a>`
                    ).join('')}
                </div>
            ` : '';
            
            const badgesHtml = `
                <div style="display: flex; gap: 8px; justify-content: center; margin-bottom: 15px; flex-wrap: wrap;">
                    <span class="node-number-badge">[${nodeNumber}]</span>
                    <span class="role-badge" style="background-color: ${roleColor};">${node.role || 'Any'}</span>
                    <span class="stage-badge">${node.stage || 'General'}</span>
                </div>
            `;

            container.innerHTML = `
                ${badgesHtml}
                <h3>${node.title}</h3>
                ${descriptionHtml}
                ${timeHtml}
                ${tipsHtml}
                ${linksHtml}
                <div class="preview-buttons">
                    ${buttonsHtml}
                </div>
            `;
        }

        function renderInteractivePreview(container) {
            // Interactive preview allows clicking through the flow
            if (!interactiveCurrentNodeId) {
                interactiveCurrentNodeId = startNodeId || (nodes.length > 0 ? nodes[0].id : null);
                interactiveHistory = [];
            }

            const node = nodes.find(n => n.id === interactiveCurrentNodeId);
            
            if (!node) {
                container.innerHTML = '<div class="empty-state"><div class="empty-state-icon">⚠️</div><p>No start node set. Click the ★ button on a node to set it as the start.</p></div>';
                return;
            }

            // Calculate numbers
            calculateNodeNumbers();
            
            const roleColor = roleColors[node.role] || roleColors['Any'];
            const nodeNumber = node.calculatedNumber || '?';

            let buttonsHtml = '';
            
            // Check if ALL connections lead to END (true endpoint)
            const allConnectionsEnd = node.connections.length > 0 && node.connections.every(c => c.target === 'END');
            
            if (node.connections.length === 0 || allConnectionsEnd) {
                // True endpoint - only show Start Over
                buttonsHtml = '<button class="preview-btn secondary" onclick="interactiveStartOver()">Start Over</button>';
            } else {
                if (interactiveHistory.length > 0) {
                    buttonsHtml += '<button class="preview-btn secondary" onclick="interactiveGoBack()">Back</button>';
                }
                
                if (node.type === 'decision') {
                    // Decision nodes show each branch as a labeled button
                    node.connections.forEach((conn, idx) => {
                        const label = conn.label || `Option ${idx + 1}`;
                        
                        if (conn.target === 'END') {
                            // END branches get special styling and trigger start over
                            buttonsHtml += `<button class="preview-btn" onclick="interactiveNavigate('${conn.target}')">${label}</button>`;
                        } else {
                            buttonsHtml += `<button class="preview-btn" onclick="interactiveNavigate('${conn.target}')">${label}</button>`;
                        }
                    });
                } else if (node.connections.length > 0) {
                    // Info nodes show Next button
                    const firstConnection = node.connections[0];
                    buttonsHtml += `<button class="preview-btn" onclick="interactiveNavigate('${firstConnection.target}')">Next</button>`;
                }
            }

            const pathIndicator = interactiveHistory.length > 0 
                ? `<div class="path-indicator">Step ${interactiveHistory.length + 1} of flow</div>` 
                : '<div class="path-indicator">Start of flow</div>';

            const descriptionHtml = node.type !== 'decision' && node.description ? `<p>${node.description}</p>` : '';
            
            const badgesHtml = `
                <div style="display: flex; gap: 8px; justify-content: center; margin-bottom: 15px; flex-wrap: wrap;">
                    <span class="node-number-badge">[${nodeNumber}]</span>
                    <span class="role-badge" style="background-color: ${roleColor};">${node.role || 'Any'}</span>
                    <span class="stage-badge">${node.stage || 'General'}</span>
                </div>
            `;

            container.innerHTML = `
                ${badgesHtml}
                <h3>${node.title}</h3>
                ${descriptionHtml}
                <div class="preview-buttons">
                    ${buttonsHtml}
                </div>
                ${pathIndicator}
            `;
        }

        // Interactive preview navigation functions (global scope for onclick)
        window.interactiveNavigate = function(targetId) {
            if (targetId === 'END') {
                // Show end state
                const container = document.getElementById('previewNode');
                container.innerHTML = `
                    <h3>End of Flow</h3>
                    <p>You've reached the end of this path.</p>
                    <div class="preview-buttons">
                        <button class="preview-btn secondary" onclick="interactiveStartOver()">Start Over</button>
                    </div>
                `;
                return;
            }
            interactiveHistory.push(interactiveCurrentNodeId);
            interactiveCurrentNodeId = targetId;
            updatePreview();
        };

        window.interactiveGoBack = function() {
            if (interactiveHistory.length > 0) {
                interactiveCurrentNodeId = interactiveHistory.pop();
                updatePreview();
            }
        };

        window.interactiveStartOver = function() {
            interactiveHistory = [];
            interactiveCurrentNodeId = startNodeId || (nodes.length > 0 ? nodes[0].id : null);
            updatePreview();
        };

        // Preview mode toggle
        document.getElementById('staticModeBtn').addEventListener('click', () => {
            previewMode = 'static';
            document.getElementById('staticModeBtn').classList.add('active');
            document.getElementById('interactiveModeBtn').classList.remove('active');
            document.getElementById('diagramModeBtn').classList.remove('active');
            updatePreview();
        });

        document.getElementById('interactiveModeBtn').addEventListener('click', () => {
            previewMode = 'interactive';
            interactiveCurrentNodeId = startNodeId || (nodes.length > 0 ? nodes[0].id : null);
            interactiveHistory = [];
            document.getElementById('staticModeBtn').classList.remove('active');
            document.getElementById('interactiveModeBtn').classList.add('active');
            document.getElementById('diagramModeBtn').classList.remove('active');
            updatePreview();
        });

        document.getElementById('diagramModeBtn').addEventListener('click', () => {
            previewMode = 'diagram';
            document.getElementById('staticModeBtn').classList.remove('active');
            document.getElementById('interactiveModeBtn').classList.remove('active');
            document.getElementById('diagramModeBtn').classList.add('active');
            updatePreview();
        });

        // Close template modals
        document.getElementById('closeTemplateSaveModal').addEventListener('click', () => {
            document.getElementById('templateSaveModal').classList.remove('active');
        });

        document.getElementById('closeTemplateLibraryModal').addEventListener('click', () => {
            document.getElementById('templateLibraryModal').classList.remove('active');
        });

        // Save Template button
        document.getElementById('saveTemplateBtn').addEventListener('click', () => {
            if (nodes.length === 0) {
                showToast('Add at least one node before saving as template');
                return;
            }
            
            document.getElementById('templateName').value = '';
            document.getElementById('templateDescription').value = '';
            document.getElementById('templateNodeCount').textContent = `${nodes.length} node(s)`;
            document.getElementById('templateSaveModal').classList.add('active');
        });

        // Load Template button
        document.getElementById('loadTemplateBtn').addEventListener('click', () => {
            showTemplateLibrary();
        });

        // Save template function
        window.saveTemplate = function() {
            const name = document.getElementById('templateName').value.trim();
            const description = document.getElementById('templateDescription').value.trim();
            
            if (!name) {
                showToast('Please enter a template name');
                return;
            }
            
            // Get existing templates
            const templates = JSON.parse(localStorage.getItem('flowchart_templates') || '[]');
            
            // Check for duplicate names
            if (templates.find(t => t.name === name)) {
                if (!confirm(`A template named "${name}" already exists. Overwrite it?`)) {
                    return;
                }
                // Remove existing template with same name
                const index = templates.findIndex(t => t.name === name);
                templates.splice(index, 1);
            }
            
            // Create template
            const template = {
                id: Date.now().toString(),
                name: name,
                description: description,
                dateCreated: new Date().toISOString(),
                nodes: JSON.parse(JSON.stringify(nodes)),
                bannerDataUrl: bannerDataUrl,
                startNodeId: startNodeId,
                nodeCount: nodes.length
            };
            
            templates.push(template);
            localStorage.setItem('flowchart_templates', JSON.stringify(templates));
            
            document.getElementById('templateSaveModal').classList.remove('active');
            showToast(`Template "${name}" saved successfully!`, 'success');
        };

        // Show template library
        function showTemplateLibrary() {
            const templates = JSON.parse(localStorage.getItem('flowchart_templates') || '[]');
            const container = document.getElementById('templateLibraryContent');
            
            if (templates.length === 0) {
                container.innerHTML = `
                    <div class="template-empty">
                        <div style="font-size: 48px; margin-bottom: 15px;">📚</div>
                        <p style="font-size: 16px; margin-bottom: 10px;">No templates saved yet</p>
                        <p style="font-size: 14px; color: #666;">Create your first template by building a flowchart and clicking "Save Template"</p>
                    </div>
                `;
            } else {
                container.innerHTML = templates.map(template => {
                    const date = new Date(template.dateCreated).toLocaleDateString();
                    return `
                        <div class="template-card">
                            <div class="template-card-header">
                                <div>
                                    <div class="template-card-title">${template.name}</div>
                                    <div class="template-card-meta">${date} • ${template.nodeCount} nodes</div>
                                </div>
                            </div>
                            ${template.description ? `<div class="template-card-description">${template.description}</div>` : ''}
                            <div class="template-card-actions">
                                <button class="template-use-btn" onclick="loadTemplate('${template.id}')">Use Template</button>
                                <button class="template-delete-btn" onclick="deleteTemplate('${template.id}')">Delete</button>
                            </div>
                        </div>
                    `;
                }).join('');
            }
            
            document.getElementById('templateLibraryModal').classList.add('active');
        }

        // Load template
        window.loadTemplate = function(templateId) {
            const templates = JSON.parse(localStorage.getItem('flowchart_templates') || '[]');
            const template = templates.find(t => t.id === templateId);
            
            if (!template) {
                showToast('Template not found', 'error');
                return;
            }
            
            // Confirm if current work exists
            if (nodes.length > 0) {
                if (!confirm('Loading a template will replace your current flowchart. Continue?')) {
                    return;
                }
            }
            
            // Load template data
            nodes = JSON.parse(JSON.stringify(template.nodes));
            bannerDataUrl = template.bannerDataUrl || null;
            startNodeId = template.startNodeId || (nodes.length > 0 ? nodes[0].id : null);
            selectedNodeId = startNodeId;
            
            // Update banner display
            if (bannerDataUrl) {
                document.getElementById('bannerImg').src = bannerDataUrl;
                document.getElementById('bannerPreview').style.display = 'block';
                document.getElementById('uploadArea').classList.add('has-file');
                document.getElementById('uploadArea').querySelector('.upload-text').textContent = 'Banner loaded';
            } else {
                document.getElementById('bannerPreview').style.display = 'none';
                document.getElementById('uploadArea').classList.remove('has-file');
                document.getElementById('uploadArea').querySelector('.upload-text').textContent = 'Click to upload banner image';
            }
            
            // Clear filters
            activeFilters = { role: '', stage: '' };
            document.getElementById('filterRole').value = '';
            document.getElementById('filterStage').value = '';
            updateFilterIndicator();
            
            // Reset preview mode
            previewMode = 'static';
            document.getElementById('staticModeBtn').classList.add('active');
            document.getElementById('interactiveModeBtn').classList.remove('active');
            document.getElementById('diagramModeBtn').classList.remove('active');
            
            document.getElementById('templateLibraryModal').classList.remove('active');
            renderNodesList();
            updatePreview();
            saveToLocalStorage();
            showToast(`Template "${template.name}" loaded!`, 'success');
        };

        // Delete template
        window.deleteTemplate = function(templateId) {
            const templates = JSON.parse(localStorage.getItem('flowchart_templates') || '[]');
            const template = templates.find(t => t.id === templateId);
            
            if (!template) return;
            
            showConfirm('Delete Template', `Delete template "${template.name}"?`).then(confirmed => {
                if (confirmed) {
                    const filtered = templates.filter(t => t.id !== templateId);
                    localStorage.setItem('flowchart_templates', JSON.stringify(filtered));
                    showTemplateLibrary();
                    showToast('Template deleted', 'success');
                }
            });
        };
        document.getElementById('closeSearchModal').addEventListener('click', () => {
            document.getElementById('searchModal').classList.remove('active');
        });

        // Open search modal
        document.getElementById('searchBtn').addEventListener('click', () => {
            document.getElementById('searchModal').classList.add('active');
            document.getElementById('searchInput').value = '';
            document.getElementById('searchInput').focus();
            performSearch('');
        });

        // Search functionality
        document.getElementById('searchInput').addEventListener('input', (e) => {
            performSearch(e.target.value);
        });

        function performSearch(query) {
            calculateNodeNumbers();
            const resultsContainer = document.getElementById('searchResults');
            
            if (!query.trim()) {
                resultsContainer.innerHTML = `
                    <div class="search-empty">
                        <div class="search-empty-icon">🔍</div>
                        <p>Enter search terms to find nodes</p>
                    </div>
                `;
                return;
            }

            const searchTerm = query.toLowerCase();
            const results = [];

            nodes.forEach(node => {
                let relevance = 0;
                let snippets = [];

                // Search in title
                if (node.title.toLowerCase().includes(searchTerm)) {
                    relevance += 10;
                    snippets.push({ field: 'Title', text: node.title });
                }

                // Search in description
                if (node.description && node.description.toLowerCase().includes(searchTerm)) {
                    relevance += 5;
                    snippets.push({ field: 'Description', text: node.description });
                }

                // Search in role
                if (node.role && node.role.toLowerCase().includes(searchTerm)) {
                    relevance += 3;
                    snippets.push({ field: 'Role', text: node.role });
                }

                // Search in stage
                if (node.stage && node.stage.toLowerCase().includes(searchTerm)) {
                    relevance += 3;
                    snippets.push({ field: 'Stage', text: node.stage });
                }

                // Search in node number
                if (node.calculatedNumber && node.calculatedNumber.includes(searchTerm)) {
                    relevance += 8;
                    snippets.push({ field: 'Number', text: node.calculatedNumber });
                }

                if (relevance > 0) {
                    results.push({ node, relevance, snippets });
                }
            });

            // Sort by relevance
            results.sort((a, b) => b.relevance - a.relevance);

            if (results.length === 0) {
                resultsContainer.innerHTML = `
                    <div class="search-empty">
                        <div class="search-empty-icon">❌</div>
                        <p>No nodes found matching "${query}"</p>
                    </div>
                `;
                return;
            }

            // Display results
            resultsContainer.innerHTML = results.map(result => {
                const node = result.node;
                const roleColor = roleColors[node.role] || roleColors['Any'];
                
                // Highlight matching text
                const highlightText = (text) => {
                    if (!text) return '';
                    const regex = new RegExp(`(${escapeRegex(searchTerm)})`, 'gi');
                    return text.replace(regex, '<span class="search-highlight">$1</span>');
                };

                const snippet = result.snippets[0];
                const snippetHtml = snippet ? `<div class="search-result-snippet"><strong>${snippet.field}:</strong> ${highlightText(snippet.text)}</div>` : '';

                return `
                    <div class="search-result-card" onclick="jumpToNode('${node.id}')">
                        <div class="search-result-header">
                            <span class="node-number-badge">[${node.calculatedNumber}]</span>
                            <span class="role-badge" style="background-color: ${roleColor};">${node.role}</span>
                            <span class="stage-badge">${node.stage}</span>
                        </div>
                        <div class="search-result-title">${highlightText(node.title)}</div>
                        ${snippetHtml}
                    </div>
                `;
            }).join('');
        }

        function escapeRegex(string) {
            return string.replace(/[.*+?^${}()|[\]\\]/g, '\\        // Close embed modal');
        }

        window.jumpToNode = function(nodeId) {
            // Close search modal
            document.getElementById('searchModal').classList.remove('active');
            
            // Select the node
            selectedNodeId = nodeId;
            
            // Switch to appropriate view
            if (previewMode === 'interactive') {
                interactiveCurrentNodeId = nodeId;
                interactiveHistory = [];
            }
            
            // Update all views
            renderNodesList();
            updatePreview();
            
            // Scroll to node in sidebar
            setTimeout(() => {
                const nodeElement = document.querySelector(`.node-item[data-id="${nodeId}"]`);
                if (nodeElement) {
                    nodeElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            }, 100);
            
            showToast('Jumped to node', 'success');
        };

        // Quick jump to node by number
        window.quickJump = function() {
            const input = document.getElementById('jumpInput').value.trim();
            if (!input) return;

            calculateNodeNumbers();
            
            // Find node by number
            const targetNode = nodes.find(n => n.calculatedNumber === input);
            
            if (targetNode) {
                jumpToNode(targetNode.id);
                document.getElementById('jumpInput').value = '';
            } else {
                showToast(`Node [${input}] not found`, 'error');
            }
        };

        // Enter key in jump input
        document.getElementById('jumpInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                quickJump();
            }
        });

        // Initialize filters
        function initializeFilters() {
            const roleFilter = document.getElementById('filterRole');
            const stageFilter = document.getElementById('filterStage');
            
            // Populate role filter
            roleFilter.innerHTML = '<option value="">All Roles</option>';
            roles.forEach(role => {
                roleFilter.innerHTML += `<option value="${role}">${role}</option>`;
            });
            
            // Populate stage filter
            stageFilter.innerHTML = '<option value="">All Stages</option>';
            stages.forEach(stage => {
                stageFilter.innerHTML += `<option value="${stage}">${stage}</option>`;
            });
            
            // Add event listeners
            roleFilter.addEventListener('change', applyFilters);
            stageFilter.addEventListener('change', applyFilters);
        }

        function applyFilters() {
            activeFilters.role = document.getElementById('filterRole').value;
            activeFilters.stage = document.getElementById('filterStage').value;
            
            updateFilterIndicator();
            renderNodesList();
            updatePreview();
        }

        function updateFilterIndicator() {
            const indicator = document.getElementById('filterIndicator');
            const hasFilters = activeFilters.role || activeFilters.stage;
            
            if (hasFilters) {
                let text = 'Filtered: ';
                const filters = [];
                if (activeFilters.role) filters.push(activeFilters.role);
                if (activeFilters.stage) filters.push(activeFilters.stage);
                text += filters.join(', ');
                
                const filteredCount = getFilteredNodes().length;
                text += ` (${filteredCount} of ${nodes.length} nodes)`;
                
                indicator.textContent = text;
                indicator.style.display = 'block';
            } else {
                indicator.style.display = 'none';
            }
        }

        function getFilteredNodes() {
            return nodes.filter(node => {
                if (activeFilters.role && node.role !== activeFilters.role) return false;
                if (activeFilters.stage && node.stage !== activeFilters.stage) return false;
                return true;
            });
        }
        document.addEventListener('keydown', (e) => {
            if ((e.ctrlKey || e.metaKey) && e.key === 'f') {
                e.preventDefault();
                document.getElementById('searchBtn').click();
            }
            
            // Escape to close modals
            if (e.key === 'Escape') {
                document.getElementById('searchModal').classList.remove('active');
            }
        });
        document.getElementById('closeEmbedModal').addEventListener('click', () => {
            document.getElementById('embedModal').classList.remove('active');
        });

        // Get Embed Code button
        document.getElementById('embedBtn').addEventListener('click', () => {
            if (nodes.length === 0) {
                showToast('Please add at least one node before embedding.');
                return;
            }
            showEmbedModal();
        });

        function showEmbedModal() {
            const modal = document.getElementById('embedModal');
            const content = document.getElementById('embedContent');
            
            content.innerHTML = `
                <div class="embed-tabs">
                    <button class="embed-tab active" onclick="switchEmbedTab('iframe')">Embed Code</button>
                    <button class="embed-tab" onclick="switchEmbedTab('deploy')">Deployment Guide</button>
                    <button class="embed-tab" onclick="switchEmbedTab('download')">Download Package</button>
                </div>

                <!-- Tab 1: Iframe Embed Code -->
                <div class="embed-tab-content active" id="tab-iframe">
                    <div class="embed-section">
                        <h3>Step 1: Host Your Flowchart</h3>
                        <p>First, you need to host the flowchart HTML file online. See the "Deployment Guide" tab for easy hosting options.</p>
                    </div>

                    <div class="embed-section">
                        <h3>Step 2: Iframe Height</h3>
                        <p>Set the height for your embedded flowchart:</p>
                        <input type="number" id="iframeHeight" class="embed-input" value="600" min="300" max="1200" onchange="updateIframeCode()">
                    </div>

                    <div class="embed-section">
                        <h3>Step 3: Copy Embed Code</h3>
                        <p>Replace <code>YOUR-HOSTED-URL</code> with your actual flowchart URL from Step 1:</p>
                        <div class="embed-code-box" id="iframeCodeBox">
                            <code id="iframeCode"></code>
                        </div>
                        <button class="btn btn-primary" onclick="copyIframeCode()">Copy Embed Code</button>
                    </div>

                    <div class="embed-section">
                        <h3>For iCIMS Users</h3>
                        <p style="font-size: 13px;">Paste this iframe code into your iCIMS career site HTML editor. If iframes are blocked, use a direct link button instead or contact your iCIMS admin to enable iframe permissions.</p>
                    </div>
                </div>

                <!-- Tab 2: Deployment Guide -->
                <div class="embed-tab-content" id="tab-deploy">
                    <p style="margin-bottom: 20px; color: #666;">Choose a free hosting platform to publish your flowchart:</p>

                    <div class="deployment-card">
                        <h4>🚀 GitHub Pages (Recommended for Beginners)</h4>
                        <ul class="deployment-steps">
                            <li data-step="1">Create a free GitHub account at github.com</li>
                            <li data-step="2">Create a new repository (e.g., "flowchart")</li>
                            <li data-step="3">Upload your exported HTML file (rename to index.html)</li>
                            <li data-step="4">Go to Settings → Pages</li>
                            <li data-step="5">Select "main" branch and "/ (root)" folder</li>
                            <li data-step="6">Click Save and wait 2-3 minutes</li>
                            <li data-step="7">Your URL: https://USERNAME.github.io/flowchart/</li>
                        </ul>
                    </div>

                    <div class="deployment-card">
                        <h4>⚡ Netlify Drop (Fastest)</h4>
                        <ul class="deployment-steps">
                            <li data-step="1">Go to app.netlify.com/drop</li>
                            <li data-step="2">Drag and drop your HTML file</li>
                            <li data-step="3">Instantly get a URL like: random-name.netlify.app</li>
                            <li data-step="4">Copy URL for your iframe code</li>
                            <li data-step="5">Optional: Create free account to customize URL</li>
                        </ul>
                    </div>

                    <div class="deployment-card">
                        <h4>🔷 Vercel (Professional)</h4>
                        <ul class="deployment-steps">
                            <li data-step="1">Go to vercel.com and sign up</li>
                            <li data-step="2">Click "Add New Project"</li>
                            <li data-step="3">Upload your HTML file</li>
                            <li data-step="4">Click Deploy</li>
                            <li data-step="5">Get URL like: flowchart-xyz.vercel.app</li>
                        </ul>
                    </div>
                </div>

                <!-- Tab 3: Download Package -->
                <div class="embed-tab-content" id="tab-download">
                    <div class="embed-section">
                        <h3>Complete Deployment Package</h3>
                        <p>Download a ZIP file containing everything you need:</p>
                        <ul style="margin: 15px 0; padding-left: 20px; color: #666; font-size: 14px;">
                            <li>index.html - Your interactive flowchart</li>
                            <li>README.md - Complete deployment instructions</li>
                            <li>EMBEDDING.txt - Pre-configured iframe code</li>
                            <li>test-embed.html - Test page for local preview</li>
                        </ul>
                        <button class="btn btn-primary" onclick="downloadDeploymentPackage()" style="width: 100%; padding: 15px; font-size: 15px;">📦 Download Deployment Package</button>
                    </div>

                    <div class="embed-section" style="margin-top: 30px;">
                        <h3>What's Next?</h3>
                        <ol style="padding-left: 20px; color: #666; font-size: 14px; line-height: 1.8;">
                            <li>Download the package above</li>
                            <li>Extract the ZIP file</li>
                            <li>Read README.md for detailed instructions</li>
                            <li>Test locally by opening test-embed.html</li>
                            <li>Upload index.html to your chosen platform</li>
                            <li>Copy the iframe code from EMBEDDING.txt</li>
                            <li>Paste into iCIMS or your website</li>
                        </ol>
                    </div>
                </div>
            `;
            
            updateIframeCode();
            modal.classList.add('active');
        }

        window.switchEmbedTab = function(tabName) {
            // Update tab buttons
            document.querySelectorAll('.embed-tab').forEach(tab => tab.classList.remove('active'));
            event.target.classList.add('active');
            
            // Update tab content
            document.querySelectorAll('.embed-tab-content').forEach(content => content.classList.remove('active'));
            document.getElementById('tab-' + tabName).classList.add('active');
        };

        window.updateIframeCode = function() {
            const height = document.getElementById('iframeHeight')?.value || 600;
            const iframeCode = `<iframe src="YOUR-HOSTED-URL/index.html" width="100%" height="${height}px" frameborder="0" style="border: none; max-width: 800px; margin: 0 auto; display: block;"></iframe>`;
            
            const codeElement = document.getElementById('iframeCode');
            if (codeElement) {
                codeElement.textContent = iframeCode;
            }
        };

        window.copyIframeCode = function() {
            const code = document.getElementById('iframeCode').textContent;
            navigator.clipboard.writeText(code).then(() => {
                showToast('✓ Iframe code copied to clipboard!', 'success');
            });
        };

        window.downloadDeploymentPackage = async function() {
            if (nodes.length === 0) {
                showToast('Please add at least one node before creating a package.');
                return;
            }
            
            try {
                const zip = new JSZip();
                
                // Add index.html - make sure we're using current nodes
                const html = generatePlayerHTML();
                zip.file('index.html', html);
                
                // Add README.md
                const readme = generateReadme();
                zip.file('README.md', readme);
                
                // Add EMBEDDING.txt
                const height = document.getElementById('iframeHeight')?.value || 600;
                const embedCode = `<iframe src="YOUR-HOSTED-URL/index.html" width="100%" height="${height}px" frameborder="0" style="border: none; max-width: 800px; margin: 0 auto; display: block;"></iframe>`;
                zip.file('EMBEDDING.txt', 'IFRAME EMBED CODE\n' + '='.repeat(50) + '\n\nReplace YOUR-HOSTED-URL with your actual deployment URL:\n\n' + embedCode);
                
                // Add test-embed.html
                const testPage = generateTestPage();
                zip.file('test-embed.html', testPage);
                
                // Generate and download
                const blob = await zip.generateAsync({type: 'blob'});
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = 'flowchart-deployment-package.zip';
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
                
                showToast('✓ Deployment package downloaded!', 'success');
            } catch (error) {
                console.error('Package creation error:', error);
                showToast('Error creating package: ' + error.message, 'error');
            }
        };

        function generateReadme() {
            return `# Interactive Flowchart Deployment Guide

## What's Included

- **index.html** - Your interactive flowchart (standalone, no dependencies)
- **EMBEDDING.txt** - Ready-to-use iframe code
- **test-embed.html** - Local test page
- **README.md** - This file

## Quick Start (3 Steps)

1. **Test Locally** - Open test-embed.html in your browser to preview
2. **Deploy Online** - Upload index.html to a hosting platform (see options below)
3. **Embed** - Use the iframe code from EMBEDDING.txt

## Hosting Options (All Free)

### Option 1: GitHub Pages (Recommended)
**Best for:** Version control, easy updates, professional use

1. Create account at github.com
2. Create new repository (e.g., "flowchart")
3. Upload index.html
4. Go to Settings → Pages
5. Enable Pages (select main branch, root folder)
6. Get URL: https://YOUR-USERNAME.github.io/flowchart/
7. Wait 2-3 minutes for deployment

### Option 2: Netlify Drop (Fastest)
**Best for:** Quick testing, instant deployment

1. Go to app.netlify.com/drop
2. Drag index.html onto the page
3. Instantly get URL: https://random-name-12345.netlify.app
4. Done! (Optional: claim site to customize URL)

### Option 3: Vercel
**Best for:** Professional deployment, custom domains

1. Sign up at vercel.com
2. Click "Add New Project"
3. Upload index.html
4. Click "Deploy"
5. Get URL: https://flowchart-xyz.vercel.app

## Embedding in iCIMS

Once deployed:

1. Copy your hosted URL (e.g., https://your-site.com/index.html)
2. Open EMBEDDING.txt
3. Replace YOUR-HOSTED-URL with your actual URL
4. Paste iframe code into iCIMS HTML editor

**Note:** If iCIMS blocks iframes, create a button/link instead:
\`\`\`html
<a href="YOUR-HOSTED-URL" target="_blank" class="btn">View Flowchart</a>
\`\`\`

## Troubleshooting

**Iframe not showing?**
- Check if URL is correct and live
- Verify iframe permissions in your CMS
- Try increasing height value

**Updates not showing?**
- GitHub Pages: Wait 2-3 minutes after upload
- Netlify/Vercel: Clear browser cache (Ctrl+F5)

**Testing locally?**
- Open test-embed.html in browser
- Or open index.html directly to see standalone version

## Support

For issues or questions about the flowchart builder, refer to your organization's documentation.

---
Generated: ${new Date().toLocaleDateString()}
Version: 1.0
`;
        }

        function generateTestPage() {
            return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flowchart Embed Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 20px;
            background: #f5f7fa;
        }
        h1 {
            color: #333;
            margin-bottom: 10px;
        }
        p {
            color: #666;
            margin-bottom: 30px;
        }
        .container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .note {
            background: #fef3e6;
            border-left: 4px solid #f59e0b;
            padding: 15px;
            margin-bottom: 20px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <h1>Flowchart Embed Test</h1>
    <p>This page shows how your flowchart will look when embedded. Once deployed online, replace "index.html" below with your hosted URL.</p>
    
    <div class="note">
        <strong>Note:</strong> This is a local test. The iframe below loads index.html from the same folder. After deploying online, update the src URL.
    </div>

    <div class="container">
        <iframe src="index.html" width="100%" height="600px" frameborder="0" style="border: none; display: block;"></iframe>
    </div>
</body>
</html>`;
        }
        document.getElementById('exportBtn').addEventListener('click', () => {
            if (nodes.length === 0) {
                showToast('Please add at least one node before exporting.');
                return;
            }

            const html = generatePlayerHTML();
            
            // Show modal with HTML for easy copying
            const modal = document.getElementById('editModal');
            const modalContent = modal.querySelector('.modal-content');
            
            // Escape HTML for display in textarea
            const escapedHtml = html.replace(/</g, '&lt;').replace(/>/g, '&gt;');
            
            modalContent.innerHTML = `
                <div class="modal-header">
                    <h2>Copy HTML Code</h2>
                    <button class="close-modal" onclick="document.getElementById('editModal').classList.remove('active')">&times;</button>
                </div>
                <p style="margin-bottom: 15px; color: #666; font-size: 14px;">Copy this HTML code and paste it into iCIMS or save as <strong>flowchart.html</strong>:</p>
                <textarea id="exportTextarea" readonly style="width: 100%; height: 400px; font-family: monospace; font-size: 11px; padding: 10px; border: 1px solid #e1e4e8; border-radius: 6px; line-height: 1.4;">${html}</textarea>
                <div style="margin-top: 15px; display: flex; gap: 10px; justify-content: flex-end;">
                    <button class="btn btn-primary" onclick="const textarea = document.getElementById('exportTextarea'); textarea.select(); document.execCommand('copy'); showToast('✓ HTML copied to clipboard!', 'success');">Copy HTML</button>
                    <button class="btn btn-secondary" onclick="document.getElementById('editModal').classList.remove('active')">Close</button>
                </div>
            `;
            
            modal.classList.add('active');
            
            // Auto-select the text
            setTimeout(() => {
                const textarea = document.getElementById('exportTextarea');
                textarea.select();
            }, 100);
        });

        // Save project to file
        document.getElementById('saveProjectBtn').addEventListener('click', () => {
            const project = {
                nodes,
                bannerDataUrl,
                startNodeId,
                version: '1.0'
            };
            
            const blob = new Blob([JSON.stringify(project, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'flowchart-project.json';
            a.click();
            URL.revokeObjectURL(url);
        });

        // Import project
        document.getElementById('importBtn').addEventListener('click', () => {
            document.getElementById('importInput').click();
        });

        document.getElementById('importInput').addEventListener('change', (e) => {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = (e) => {
                    try {
                        const project = JSON.parse(e.target.result);
                        nodes = project.nodes || [];
                        bannerDataUrl = project.bannerDataUrl || null;
                        startNodeId = project.startNodeId || (nodes.length > 0 ? nodes[0].id : null);
                        selectedNodeId = startNodeId;
                        
                        if (bannerDataUrl) {
                            document.getElementById('bannerImg').src = bannerDataUrl;
                            document.getElementById('bannerPreview').style.display = 'block';
                            document.getElementById('uploadArea').classList.add('has-file');
                        }
                        
                        renderNodesList();
                        updatePreview();
                        saveToLocalStorage();
                        showToast('Project loaded successfully!', 'success');
                    } catch (error) {
                        showToast('Error loading project file. Please ensure it\'s a valid flowchart project.');
                    }
                };
                reader.readAsText(file);
            }
        });

        // LocalStorage auto-save
        function saveToLocalStorage() {
            const project = {
                nodes,
                bannerDataUrl,
                startNodeId,
                selectedNodeId,
                timestamp: new Date().toISOString()
            };
            localStorage.setItem('flowchart_autosave', JSON.stringify(project));
        }

        function loadFromLocalStorage() {
            const saved = localStorage.getItem('flowchart_autosave');
            if (saved) {
                try {
                    const project = JSON.parse(saved);
                    nodes = project.nodes || [];
                    bannerDataUrl = project.bannerDataUrl || null;
                    startNodeId = project.startNodeId || (nodes.length > 0 ? nodes[0].id : null);
                    selectedNodeId = project.selectedNodeId || startNodeId;
                    
                    if (bannerDataUrl) {
                        document.getElementById('bannerImg').src = bannerDataUrl;
                        document.getElementById('bannerPreview').style.display = 'block';
                        document.getElementById('uploadArea').classList.add('has-file');
                        document.getElementById('uploadArea').querySelector('.upload-text').textContent = 'Banner loaded';
                    }
                } catch (error) {
                    console.error('Error loading autosave:', error);
                }
            }
        }

        function generatePlayerHTML() {
            const bannerTag = bannerDataUrl ? `<img class="banner" src="${bannerDataUrl}" alt="Banner">` : '';
            const firstNodeId = startNodeId || (nodes.length > 0 ? nodes[0].id : null);
            
            return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Interactive Flowchart</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: #f5f7fa;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .flowchart-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 16px rgba(0,0,0,0.1);
            max-width: 700px;
            width: 100%;
            overflow: hidden;
        }
        .banner {
            width: 100%;
            max-height: 250px;
            object-fit: cover;
        }
        .content {
            padding: 40px;
            text-align: center;
        }
        h1 {
            font-size: 28px;
            font-weight: 600;
            color: #333;
            margin-bottom: 20px;
        }
        p {
            font-size: 16px;
            color: #666;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
        }
        button {
            padding: 14px 28px;
            background: #2d5f8d;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 15px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            min-width: 120px;
        }
        button:hover {
            background: #1e4466;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(45,95,141,0.3);
        }
        button.secondary {
            background: #6b7280;
        }
        button.secondary:hover {
            background: #4b5563;
        }
    </style>
</head>
<body>
    <div class="flowchart-container">
        ${bannerTag}
        <div class="content" id="content"></div>
    </div>
    <script>
        const flowData = ${JSON.stringify(nodes)};
        let history = [];
        let currentNodeId = '${firstNodeId}';

        function render() {
            const node = flowData.find(n => n.id === currentNodeId);
            if (!node) return;

            let buttonsHtml = '';
            
            if (node.connections.length === 0 || node.connections.some(c => c.target === 'END')) {
                buttonsHtml = '<button onclick="startOver()" class="secondary">Start Over</button>';
            } else {
                if (history.length > 0) {
                    buttonsHtml += '<button onclick="goBack()" class="secondary">Back</button>';
                }
                
                if (node.type === 'decision') {
                    // Decision nodes show labeled branch buttons
                    node.connections.forEach(conn => {
                        buttonsHtml += '<button onclick="navigate(\'' + conn.target + '\')">' + conn.label + '</button>';
                    });
                } else if (node.connections.length > 0) {
                    buttonsHtml += '<button onclick="navigate(\'' + node.connections[0].target + '\')">Next</button>';
                }
            }

            const descriptionHtml = (node.type !== 'decision' && node.description) ? '<p>' + node.description + '</p>' : '';

            document.getElementById('content').innerHTML = '<h1>' + node.title + '</h1>' + descriptionHtml + '<div class="buttons">' + buttonsHtml + '</div>';
        }

        function navigate(targetId) {
            if (targetId === 'END') return;
            history.push(currentNodeId);
            currentNodeId = targetId;
            render();
        }

        function goBack() {
            if (history.length > 0) {
                currentNodeId = history.pop();
                render();
            }
        }

        function startOver() {
            history = [];
            currentNodeId = '${firstNodeId}';
            render();
        }

        render();
    <\/script>
</body>
</html>`;
        }

        // Initialize - load from localStorage
        loadFromLocalStorage();
        initializeFilters();
        initializeDefaultTemplates();
        renderNodesList();
        updatePreview();

        // Initialize default templates
        function initializeDefaultTemplates() {
            const templates = JSON.parse(localStorage.getItem('flowchart_templates') || '[]');
            
            // Only add defaults if no templates exist
            if (templates.length === 0) {
                const defaults = getDefaultTemplates();
                localStorage.setItem('flowchart_templates', JSON.stringify(defaults));
            }
        }

        function getDefaultTemplates() {
            return [
                {
                    id: 'default-1',
                    name: 'Standard Requisition Workflow',
                    description: 'A basic recruiting workflow from requisition approval through offer acceptance',
                    dateCreated: new Date().toISOString(),
                    nodeCount: 6,
                    bannerDataUrl: null,
                    startNodeId: '1',
                    nodes: [
                        { id: '1', type: 'info', title: 'Requisition Submitted', description: 'Hiring Manager submits requisition through ATS', role: 'Hiring Manager', stage: 'Planning', connections: [{label: '', target: '2'}] },
                        { id: '2', type: 'decision', title: 'Approve Requisition?', description: '', role: 'TA Leadership', stage: 'Planning', connections: [{label: 'Approved', target: '3'}, {label: 'Rejected', target: 'END'}] },
                        { id: '3', type: 'info', title: 'Source Candidates', description: 'Recruiter searches for qualified candidates', role: 'Recruiter', stage: 'Sourcing', connections: [{label: '', target: '4'}] },
                        { id: '4', type: 'info', title: 'Screen Resumes', description: 'Review applications and conduct phone screens', role: 'Recruiter', stage: 'Screening', connections: [{label: '', target: '5'}] },
                        { id: '5', type: 'info', title: 'Conduct Interviews', description: 'Schedule and complete interview rounds', role: 'Hiring Manager', stage: 'Interviewing', connections: [{label: '', target: '6'}] },
                        { id: '6', type: 'decision', title: 'Make Offer?', description: '', role: 'Hiring Manager', stage: 'Selection', connections: [{label: 'Yes', target: 'END'}, {label: 'No', target: '3'}] }
                    ]
                },
                {
                    id: 'default-2',
                    name: 'Interview Scheduling Process',
                    description: 'Workflow for coordinating and managing interview logistics',
                    dateCreated: new Date().toISOString(),
                    nodeCount: 5,
                    bannerDataUrl: null,
                    startNodeId: '1',
                    nodes: [
                        { id: '1', type: 'info', title: 'Candidate Selected for Interview', description: 'Recruiter identifies candidate ready for interview', role: 'Recruiter', stage: 'Screening', connections: [{label: '', target: '2'}] },
                        { id: '2', type: 'info', title: 'Check Interviewer Availability', description: 'Coordinator confirms interviewer schedules', role: 'Coordinator', stage: 'Interviewing', connections: [{label: '', target: '3'}] },
                        { id: '3', type: 'info', title: 'Send Interview Invitation', description: 'System sends calendar invite to all participants', role: 'System', stage: 'Interviewing', connections: [{label: '', target: '4'}] },
                        { id: '4', type: 'decision', title: 'Candidate Confirms?', description: '', role: 'Candidate', stage: 'Interviewing', connections: [{label: 'Confirmed', target: '5'}, {label: 'Needs Reschedule', target: '2'}] },
                        { id: '5', type: 'info', title: 'Conduct Interview', description: 'Interview takes place and feedback is collected', role: 'Hiring Manager', stage: 'Interviewing', connections: [{label: '', target: 'END'}] }
                    ]
                },
                {
                    id: 'default-3',
                    name: 'Offer Management Workflow',
                    description: 'Process for preparing, approving, and extending job offers',
                    dateCreated: new Date().toISOString(),
                    nodeCount: 6,
                    bannerDataUrl: null,
                    startNodeId: '1',
                    nodes: [
                        { id: '1', type: 'info', title: 'Candidate Selected', description: 'Hiring team agrees on top candidate', role: 'Hiring Manager', stage: 'Selection', connections: [{label: '', target: '2'}] },
                        { id: '2', type: 'info', title: 'Prepare Offer Package', description: 'HR prepares offer letter and compensation details', role: 'HR/Compliance', stage: 'Offer', connections: [{label: '', target: '3'}] },
                        { id: '3', type: 'decision', title: 'Approve Offer?', description: '', role: 'TA Leadership', stage: 'Offer', connections: [{label: 'Approved', target: '4'}, {label: 'Revise', target: '2'}] },
                        { id: '4', type: 'info', title: 'Extend Offer', description: 'Recruiter presents offer to candidate', role: 'Recruiter', stage: 'Offer', connections: [{label: '', target: '5'}] },
                        { id: '5', type: 'decision', title: 'Candidate Accepts?', description: '', role: 'Candidate', stage: 'Offer', connections: [{label: 'Accepted', target: '6'}, {label: 'Declined', target: 'END'}, {label: 'Negotiating', target: '2'}] },
                        { id: '6', type: 'info', title: 'Begin Onboarding', description: 'Start new hire paperwork and orientation', role: 'HR/Compliance', stage: 'Onboarding', connections: [{label: '', target: 'END'}] }
                    ]
                }
            ];
        }
    </script>
</body>
</html>
