return {
    type = "table",
    entries = {
        timer = {
            type = "table",
            entries = {
                name = {
                    description = "Timer caption",
                    type = "string",
                    default = "Respawn"
                },
                duration = {
                    description = "Timer duration in seconds",
                    type = "number",
                    range = {
                        min = 0,
                        max = 6e3
                    },
                    default = 5
                },
                color = {
                    description = "Timer fill color as hex string",
                    type = "string",
                    range = {
                        min = "000000",
                        max = "FFFFFF"
                    },
                    default = "FF00FF"
                }
            }
        }
    }
}