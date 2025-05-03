package main

import "time"

func (app *application) CleanupOldUnsavedItems() {
	for {
		select {
		case <-app.ctx.Done():
			app.logger.Info("items cleanup shutting down gracefully")
			return
		default:
			startTime := time.Now()
			err := app.models.Items.CleanupItems(startTime.Add(-1 * app.config.cleanup.itemsCleanupBeforeDuration))
			if err != nil {
				app.logInternalError("app.models.Items.CleanupItems failed", err)
			}
			timer := time.NewTimer(time.Until(startTime.Add(app.config.cleanup.itemsCleanupPeriod)))
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
