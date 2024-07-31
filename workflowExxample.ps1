workflow Sample-Workflow {
    Write-Output "Workflow başlıyor."

    parallel {
        InlineScript {
            Write-Output "İlk paralel görev, 5 saniye bekliyor."
            Start-Sleep -Seconds 20
            Write-Output "İlk paralel görev tamamlandı."
        }

        InlineScript {
            Write-Output "İkinci paralel görev, 3 saniye bekliyor."
            Start-Sleep -Seconds 3
            Write-Output "İkinci paralel görev tamamlandı."
        }
    }

    Write-Output "Workflow tamamlandı."
}

# Workflow'u çalıştırma
Sample-Workflow
########################