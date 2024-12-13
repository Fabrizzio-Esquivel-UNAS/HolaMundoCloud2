# Stop all running Docker containers
Write-Host "Stopping all Docker containers..."
try {
    $containers = docker ps -q
    if ($containers) {
        docker stop $containers | Out-Null
        Write-Host "All running containers stopped."
    } else {
        Write-Host "No running containers to stop."
    }
} catch {
    Write-Host "Error stopping containers: $_"
}

# Remove all Docker containers
Write-Host "Removing all Docker containers..."
try {
    $containers = docker ps -aq
    if ($containers) {
        docker rm $containers | Out-Null
        Write-Host "All containers removed."
    } else {
        Write-Host "No containers to remove."
    }
} catch {
    Write-Host "Error removing containers: $_"
}

# Remove all Docker images
Write-Host "Removing all Docker images..."
try {
    $images = docker images -q
    if ($images) {
        docker rmi $images | Out-Null
        Write-Host "All images removed."
    } else {
        Write-Host "No Docker images to remove."
    }
} catch {
    Write-Host "Error removing images: $_"
}
