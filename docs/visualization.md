# Visualization Guide

This document explains how to use visualization tools for Autoware development.

## Available Visualization Tools

The development environment includes several visualization tools:

1. **Lichtblick** (Foxglove Studio): Modern visualization platform for robotics

## Lichtblick (Foxglove Studio)

Lichtblick is an OSS fork of "Foxglove Studio" and is a powerful visualization tool for robotics data.

### Starting Lichtblick

```bash
# Start the bridge and Lichtblick client
foxglove

# With custom port
foxglove port:=8766

# With ROS arguments
foxglove use_sim_time:=True

# For more options
foxglove --help
```

## Additional Resources

- [Lichtblick (Foxglove Studio)](https://github.com/lichtblick-suite/lichtblick)
