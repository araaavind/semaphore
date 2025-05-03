package main

import "time"

func (app *application) CleanupTokens() {
	for {
		select {
		case <-app.ctx.Done():
			return
		default:
			startTime := time.Now()
			err := app.models.Tokens.DeleteExpiredTokens()
			if err != nil {
				app.logInternalError("app.models.Tokens.CleanupTokens failed", err)
			}
			timer := time.NewTimer(time.Until(startTime.Add(app.config.cleanup.tokensCleanupPeriod)))
			select {
			case <-app.ctx.Done():
				timer.Stop()
				return
			case <-timer.C:
				// Continue with the next iteration
			}
		}
	}
}
