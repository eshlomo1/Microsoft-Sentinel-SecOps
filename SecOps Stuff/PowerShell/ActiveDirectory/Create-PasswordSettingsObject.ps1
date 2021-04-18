New-ADFineGrainedPasswordPolicy -Name ADMLpso2 -Precedence 200 `
-MinPasswordLength 12 -MaxPasswordAge "21" -MinPasswordAge "2" `
-PasswordHistoryCount 50 -ComplexityEnabled:$true `
-Description "ADML policy 2" -LockoutDuration "4:00" `
-LockoutObservationWindow "4:00" -LockoutThreshold 3 `
-ReversibleEncryptionEnabled:$false